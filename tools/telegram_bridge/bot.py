import os
import sys
import re
import html
import json
import time
import shutil
import sqlite3
import logging
import asyncio
import subprocess
from datetime import datetime
from pathlib import Path

# Force UTF-8 output on Windows console
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from telegram import Update
from telegram.constants import ParseMode, ChatAction
from telegram.ext import (
    ApplicationBuilder,
    CommandHandler,
    MessageHandler,
    ContextTypes,
    filters,
)

# Setup Logging
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO,
)
logger = logging.getLogger("TelegramDevBridge")

# Base Directories & Database Paths
CURRENT_DIR = Path(__file__).resolve().parent
DEFAULT_WORKSPACE_DIR = CURRENT_DIR.parent.parent
STUDIO_PROJECTS_DIR = Path(r"C:\Users\jundi\StudioProjects")
CONFIG_PATH = CURRENT_DIR / "config.json"
AGY_EXE = r"C:\Users\jundi\.gemini\bin\agy.exe"

CONVERSATION_DB_PATH = Path(r"C:\Users\jundi\.gemini\antigravity-cli\conversation_summaries.db")
CLI_CONVERSATIONS_DIR = Path(r"C:\Users\jundi\.gemini\antigravity-cli\conversations")
IDE_CONVERSATIONS_DIR = Path(r"C:\Users\jundi\.gemini\antigravity\conversations")
CLI_BRAIN_DIR = Path(r"C:\Users\jundi\.gemini\antigravity-cli\brain")
IDE_BRAIN_DIR = Path(r"C:\Users\jundi\.gemini\antigravity\brain")

AVAILABLE_MODELS = [
    "gemini-3.8-flash-high",
    "claude-sonnet-4-6",
    "claude-opus-4-6-thinking",
    "gpt-oss-120b-medium",
    "gemini-3.8-flash-medium",
    "gemini-3.8-flash-low",
]

def load_config() -> dict:
    if not CONFIG_PATH.exists():
        raise FileNotFoundError(f"Config file not found at {CONFIG_PATH}")
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        return json.load(f)

def save_config(config: dict):
    with open(CONFIG_PATH, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2)

CONFIG = load_config()
BOT_TOKEN = CONFIG.get("bot_token", "").strip()
ALLOWED_USER_ID = int(CONFIG.get("allowed_user_id", 0))

# Global tracking for active process and reset state
ACTIVE_PROCESS = None
RESET_NEXT_SESSION = False

def get_workspace_dir() -> Path:
    config = load_config()
    custom_ws = config.get("workspace_dir")
    if custom_ws:
        p = Path(custom_ws)
        if p.exists() and p.is_dir():
            return p
    return DEFAULT_WORKSPACE_DIR

def is_authorized(user_id: int) -> bool:
    return user_id == ALLOWED_USER_ID

async def check_auth(update: Update) -> bool:
    user = update.effective_user
    if not user or not is_authorized(user.id):
        logger.warning(f"Unauthorized access attempt by user {user.id if user else 'Unknown'}")
        if update.effective_message:
            await update.effective_message.reply_text(
                f"<b>Akses Ditolak.</b>\nID Akun Anda (<code>{user.id if user else 'N/A'}</code>) belum diizinkan mengontrol PC ini.",
                parse_mode=ParseMode.HTML,
            )
        return False
    return True

def get_rel_path(raw_path: str) -> str:
    if not raw_path:
        return ""
    try:
        p = Path(raw_path)
        ws = get_workspace_dir()
        if p.is_relative_to(ws):
            return str(p.relative_to(ws)).replace("\\", "/")
        return p.name
    except Exception:
        return Path(raw_path).name

def format_duration(seconds: int) -> str:
    m, s = divmod(seconds, 60)
    if m > 0:
        return f"{m}m {s}s"
    return f"{s}s"

# ==================== TEXT FORMATTING & SPLITTING ====================

def md_to_telegram_html(text: str) -> str:
    """Konversi Markdown umum ke Telegram HTML yang valid dan bersih."""
    code_blocks = []
    def save_code_block(match):
        code = match.group(1)
        code_esc = code.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        code_blocks.append(f"<pre><code>{code_esc}</code></pre>")
        return f"TOKEN_CODE_BLOCK_{len(code_blocks)-1}_TOKEN"
    text = re.sub(r"```(?:\w+)?\n?(.*?)```", save_code_block, text, flags=re.DOTALL)

    inline_codes = []
    def save_inline_code(match):
        code = match.group(1)
        code_esc = code.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        inline_codes.append(f"<code>{code_esc}</code>")
        return f"TOKEN_INLINE_CODE_{len(inline_codes)-1}_TOKEN"
    text = re.sub(r"`([^`]+)`", save_inline_code, text)

    text = text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    text = re.sub(r"(?m)^---+$", "----------------------------------------", text)
    text = re.sub(r"(?m)^#{1,6}\s*(.+)$", r"<b>\1</b>", text)
    text = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", text)
    text = re.sub(r"__(.+?)__", r"<b>\1</b>", text)

    text = re.sub(r"(?<!\w)\*([^*]+?)\*(?!\w)", r"<i>\1</i>", text)
    text = re.sub(r"(?<!\w)_([^_]+?)_(?!\w)", r"<i>\1</i>", text)

    def format_link(m):
        label, url = m.group(1), m.group(2)
        if url.startswith(("http://", "https://", "tg://")):
            return f'<a href="{url}">{label}</a>'
        return f"<code>{label}</code>"
    text = re.sub(r"\[(.+?)\]\((.+?)\)", format_link, text)

    text = re.sub(r"(?m)^[-*]\s+", "• ", text)

    for idx, block in enumerate(inline_codes):
        text = text.replace(f"TOKEN_INLINE_CODE_{idx}_TOKEN", block)
    for idx, block in enumerate(code_blocks):
        text = text.replace(f"TOKEN_CODE_BLOCK_{idx}_TOKEN", block)

    return text

def split_markdown_into_chunks(text: str, max_chars: int = 3500) -> list[str]:
    """Membagi teks panjang pada jeda baris agar tidak memotong tag kode atau struktur penting."""
    if len(text) <= max_chars:
        return [text]

    lines = text.split("\n")
    chunks = []
    current_chunk = []
    current_len = 0
    in_code_block = False

    for line in lines:
        if line.strip().startswith("```"):
            in_code_block = not in_code_block

        if len(line) > max_chars:
            if current_chunk:
                chunks.append("\n".join(current_chunk))
                current_chunk = []
                current_len = 0
            for i in range(0, len(line), max_chars):
                chunks.append(line[i:i + max_chars])
            continue

        line_len = len(line) + 1
        if current_len + line_len > max_chars and not in_code_block and current_chunk:
            chunks.append("\n".join(current_chunk))
            current_chunk = [line]
            current_len = line_len
        else:
            current_chunk.append(line)
            current_len += line_len

    if current_chunk:
        chunks.append("\n".join(current_chunk))

    return chunks

async def split_and_send(update: Update, text: str, parse_mode=ParseMode.HTML):
    """Kirim pesan panjang dengan membaginya secara aman dan menerapkan formatting HTML."""
    if not text.strip():
        return

    chunks = split_markdown_into_chunks(text, max_chars=3500)

    for chunk in chunks:
        if parse_mode == ParseMode.HTML:
            html_text = md_to_telegram_html(chunk)
            try:
                await update.effective_message.reply_text(
                    html_text,
                    parse_mode=ParseMode.HTML,
                    disable_web_page_preview=True,
                )
            except Exception as e:
                logger.warning(f"Gagal mengirim pesan HTML: {e}. Mengirim fallback teks polos.")
                clean_plain = re.sub(r"<[^>]+>", "", html_text)
                await update.effective_message.reply_text(clean_plain or chunk)
        else:
            try:
                await update.effective_message.reply_text(chunk, parse_mode=parse_mode)
            except Exception:
                await update.effective_message.reply_text(chunk)

# ==================== SESSION MANAGEMENT ====================

def get_recent_conversations(limit: int = 8) -> list[dict]:
    """Mengambil daftar riwayat sesi percakapan dari SQLite database Antigravity."""
    if not CONVERSATION_DB_PATH.exists():
        return []
    try:
        conn = sqlite3.connect(CONVERSATION_DB_PATH, timeout=2.0)
        cur = conn.cursor()
        query = """
            SELECT conversation_id, title, preview, last_modified_time, workspace_uris, app_data_dir
            FROM conversation_summaries
            ORDER BY last_modified_time DESC
            LIMIT ?
        """
        cur.execute(query, (limit,))
        rows = cur.fetchall()
        conn.close()

        results = []
        for r in rows:
            cid, title, preview, last_mod, ws, app_data = r
            ws_name = ""
            ws_path = ""
            if ws:
                try:
                    ws_list = json.loads(ws)
                    if ws_list:
                        raw_uri = ws_list[0]
                        clean_path = raw_uri.replace("file:///", "").replace("%3A", ":").replace("/", "\\")
                        ws_path = clean_path
                        ws_name = Path(clean_path).name
                except Exception:
                    pass

            results.append({
                "id": cid,
                "title": title or "Percakapan Baru",
                "preview": (preview or "").replace("\n", " ").strip()[:65],
                "time": last_mod[:16] if last_mod else "",
                "workspace": ws_name,
                "workspace_path": ws_path,
                "source": app_data,
            })
        return results
    except Exception as e:
        logger.error(f"Error reading conversation_summaries: {e}")
        return []

def get_conversation_by_id_or_prefix(query: str) -> dict | None:
    """Cari percakapan spesifik berdasarkan ID persis atau awalan prefix ID."""
    if not CONVERSATION_DB_PATH.exists():
        return None
    try:
        conn = sqlite3.connect(CONVERSATION_DB_PATH, timeout=2.0)
        cur = conn.cursor()
        q = """
            SELECT conversation_id, title, preview, last_modified_time, workspace_uris, app_data_dir
            FROM conversation_summaries
            WHERE conversation_id = ? OR conversation_id LIKE ?
            LIMIT 1
        """
        cur.execute(q, (query, f"{query}%"))
        r = cur.fetchone()
        conn.close()
        if not r:
            return None
        cid, title, preview, last_mod, ws, app_data = r
        ws_name = ""
        ws_path = ""
        if ws:
            try:
                ws_list = json.loads(ws)
                if ws_list:
                    clean_path = ws_list[0].replace("file:///", "").replace("%3A", ":").replace("/", "\\")
                    ws_path = clean_path
                    ws_name = Path(clean_path).name
            except Exception:
                pass
        return {
            "id": cid,
            "title": title or "Percakapan Baru",
            "preview": (preview or "").replace("\n", " ").strip()[:65],
            "time": last_mod[:16] if last_mod else "",
            "workspace": ws_name,
            "workspace_path": ws_path,
            "source": app_data,
        }
    except Exception:
        return None

def prepare_conversation_for_cli(cid: str) -> bool:
    """Sinkronkan data database & brain sesi dari folder IDE ke antigravity-cli jika diperlukan."""
    cli_db = CLI_CONVERSATIONS_DIR / f"{cid}.db"
    ide_db = IDE_CONVERSATIONS_DIR / f"{cid}.db"

    if not cli_db.exists() and ide_db.exists():
        try:
            CLI_CONVERSATIONS_DIR.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ide_db, cli_db)
            for ext in [".db-wal", ".db-shm"]:
                f = IDE_CONVERSATIONS_DIR / f"{cid}{ext}"
                if f.exists():
                    shutil.copy2(f, CLI_CONVERSATIONS_DIR / f"{cid}{ext}")
        except Exception as e:
            logger.warning(f"Could not copy IDE db to CLI: {e}")

    cli_brain = CLI_BRAIN_DIR / cid
    ide_brain = IDE_BRAIN_DIR / cid
    if not cli_brain.exists() and ide_brain.exists():
        try:
            CLI_BRAIN_DIR.mkdir(parents=True, exist_ok=True)
            shutil.copytree(ide_brain, cli_brain)
        except Exception as e:
            logger.warning(f"Could not copy IDE brain to CLI: {e}")

    return cli_db.exists()

# ==================== LIVE STATUS UI ====================

def build_status_text(model_name: str, mode_label: str, elapsed_sec: int, current_action: str, recent_actions: list, modified_files: set, session_title: str = "") -> str:
    dur_str = format_duration(elapsed_sec)
    
    text = f"<b>[Antigravity: {model_name}{mode_label}]</b>\n"
    if session_title:
        text += f"Sesi: <i>{html.escape(session_title)}</i>\n"
    text += f"Durasi: <code>{dur_str}</code>\n"
    text += "----------------------------------------\n"
    text += f"<b>Status:</b> {html.escape(current_action)}\n\n"

    if recent_actions:
        text += "<b>Langkah Terakhir:</b>\n"
        for act in recent_actions[-3:]:
            text += f"• {html.escape(act)}\n"
        text += "\n"

    if modified_files:
        text += f"<b>File Dimodifikasi ({len(modified_files)}):</b>\n"
        for f in sorted(list(modified_files))[-5:]:
            text += f"• <code>{html.escape(f)}</code>\n"
        if len(modified_files) > 5:
            text += f"• <i>...dan {len(modified_files) - 5} file lainnya</i>\n"
        text += "\n"

    text += "Ketik <code>/stop</code> untuk membatalkan proses."
    return text

# ==================== COMMAND HANDLERS ====================

async def start_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await check_auth(update):
        return

    config = load_config()
    current_model = config.get("model", "gemini-3.8-flash-high")
    active_cid = config.get("active_conversation_id", "")
    ws = get_workspace_dir()

    active_session_info = "Otomatis (melanjutkan sesi terakhir)"
    if active_cid:
        sess_data = get_conversation_by_id_or_prefix(active_cid)
        if sess_data:
            active_session_info = f"<b>{sess_data['title']}</b> (<code>{active_cid[:8]}...</code>)"
        else:
            active_session_info = f"<code>{active_cid[:8]}...</code>"

    msg = (
        "<b>Antigravity Telegram Bridge</b>\n\n"
        f"<b>Model Aktif:</b> <code>{current_model}</code>\n"
        f"<b>Workspace:</b> <code>{ws.name}</code> (<code>{ws}</code>)\n"
        f"<b>Sesi Aktif:</b> {active_session_info}\n\n"
        "<b>Perintah Sesi & Percakapan:</b>\n"
        "• <code>/session</code> atau <code>/sessions</code> - Lihat & pilih riwayat sesi percakapan\n"
        "• <code>/session &lt;nomor&gt;</code> - Lanjutkan sesi tertentu (contoh: <code>/session 2</code>)\n"
        "• <code>/new</code> - Reset percakapan untuk memulai sesi baru\n\n"
        "<b>Perintah Kontrol:</b>\n"
        "• <code>/stop</code> atau <code>/cancel</code> - Hentikan proses aktif seketika\n"
        "• <code>/project</code> - Lihat atau ganti workspace proyek\n"
        "• <code>/model</code> - Ganti model AI (Claude, GPT, Gemini)\n"
        "• <code>/ss</code> - Screenshot emulator Android aktif\n"
        "• <code>/analyze</code> - Jalankan flutter analyze di PC\n"
        "• <code>/git</code> - Cek status commit & perubahan git\n"
        "• <code>/run &lt;perintah&gt;</code> - Jalankan perintah shell di PC\n\n"
        "<b>Mode Perintah Antigravity:</b>\n"
        "• <code>/plan &lt;tugas&gt;</code> - Susun rencana aksi bertahap sebelum eksekusi\n"
        "• <code>/goal &lt;tugas&gt;</code> - Eksekusi tugas tuntas secara mandiri\n"
        "• <code>/grill-me &lt;topik&gt;</code> - Diskusi kritis arsitektur & wawancara fitur\n"
        "• <code>/learn &lt;aturan&gt;</code> - Catat pembelajaran atau konvensi baru\n"
        "• <code>/compact</code> - Ringkas riwayat percakapan\n\n"
        "<b>Kirim Pesan Biasa:</b>\n"
        "Ketik instruksi atau pertanyaan secara langsung untuk dikerjakan oleh Antigravity."
    )
    await update.effective_message.reply_text(msg, parse_mode=ParseMode.HTML)

async def session_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handler untuk melihat, memilih, dan melanjutkan sesi percakapan Antigravity."""
    global RESET_NEXT_SESSION
    if not await check_auth(update):
        return

    config = load_config()
    active_cid = config.get("active_conversation_id", "").strip()
    recent = get_recent_conversations(8)

    # 1. Tanpa argumen: Tampilkan daftar sesi terakhir
    if not context.args:
        active_label = "<i>(Belum ada sesi spesifik - otomatis melanjutkan sesi terbaru)</i>"
        if active_cid:
            cur = get_conversation_by_id_or_prefix(active_cid)
            if cur:
                active_label = f"<b>{html.escape(cur['title'])}</b> (<code>{active_cid[:8]}...</code>)"
            else:
                active_label = f"<code>{active_cid[:8]}...</code>"

        lines = [
            "<b>Daftar Sesi Percakapan Antigravity</b>\n",
            f"<b>Sesi Aktif Saat Ini:</b>\n{active_label}\n",
            "<b>Riwayat Sesi Terakhir:</b>",
        ]

        if not recent:
            lines.append("<i>(Belum ada riwayat sesi yang tercatat)</i>")
        else:
            for i, s in enumerate(recent, 1):
                is_active = (s["id"] == active_cid)
                tag = " <b>[AKTIF]</b>" if is_active else ""
                ws_info = f" • Proyek: <code>{html.escape(s['workspace'])}</code>" if s["workspace"] else ""
                time_info = f" • {html.escape(s['time'])}" if s["time"] else ""
                prev = f"\n   <i>Preview: {html.escape(s['preview'])}...</i>" if s["preview"] else ""
                lines.append(
                    f"<b>[{i}]</b> <b>{html.escape(s['title'])}</b>{tag}\n"
                    f"   ID: <code>{s['id'][:8]}...</code>{ws_info}{time_info}{prev}\n"
                )

        lines.append(
            "----------------------------------------\n"
            "<b>Cara Melanjutkan Sesi:</b>\n"
            "• Ketik nomor: <code>/session &lt;nomor&gt;</code> (contoh: <code>/session 1</code>)\n"
            "• Atau ketik ID: <code>/session &lt;id&gt;</code> (contoh: <code>/session 13fa4e39</code>)\n"
            "• Buat sesi baru: <code>/session new</code> atau <code>/new</code>"
        )
        await split_and_send(update, "\n".join(lines), parse_mode=ParseMode.HTML)
        return

    sub_arg = context.args[0].strip()

    # 2. Reset / New session
    if sub_arg.lower() in ["new", "reset"]:
        RESET_NEXT_SESSION = True
        config["active_conversation_id"] = ""
        save_config(config)
        await update.effective_message.reply_text(
            "<b>Sesi Antigravity Direset.</b>\nPesan Anda berikutnya akan otomatis memulai percakapan baru dari awal.",
            parse_mode=ParseMode.HTML
        )
        return

    # 3. Info sesi aktif saat ini
    if sub_arg.lower() in ["info", "current"]:
        if not active_cid:
            await update.effective_message.reply_text(
                "Tidak ada sesi spesifik yang di-pin saat ini. Bot secara default melanjutkan sesi terbaru.",
                parse_mode=ParseMode.HTML
            )
            return
        cur = get_conversation_by_id_or_prefix(active_cid)
        if not cur:
            await update.effective_message.reply_text(
                f"Sesi aktif memiliki ID <code>{active_cid}</code> tetapi ringkasannya belum ditemukan di database.",
                parse_mode=ParseMode.HTML
            )
            return

        msg = (
            "<b>Informasi Sesi Aktif</b>\n\n"
            f"• <b>Judul:</b> {html.escape(cur['title'])}\n"
            f"• <b>ID:</b> <code>{cur['id']}</code>\n"
            f"• <b>Proyek:</b> <code>{cur['workspace'] or 'Umum'}</code>\n"
            f"• <b>Waktu Terakhir:</b> <code>{cur['time']}</code>\n"
            f"• <b>Preview:</b> <i>{html.escape(cur['preview'])}</i>"
        )
        await update.effective_message.reply_text(msg, parse_mode=ParseMode.HTML)
        return

    # 4. Pilih berdasarkan nomor urut (misal /session 1, /session 2)
    target_session = None
    if sub_arg.isdigit():
        idx = int(sub_arg) - 1
        if 0 <= idx < len(recent):
            target_session = recent[idx]
        else:
            await update.effective_message.reply_text(
                f"Nomor sesi <code>{sub_arg}</code> tidak valid. Ketik <code>/session</code> untuk melihat daftar nomor yang tersedia.",
                parse_mode=ParseMode.HTML
            )
            return
    else:
        # Cari berdasarkan ID / prefix
        target_session = get_conversation_by_id_or_prefix(sub_arg)
        if not target_session:
            await update.effective_message.reply_text(
                f"Sesi dengan ID/awalan <code>{html.escape(sub_arg)}</code> tidak ditemukan di riwayat Antigravity.",
                parse_mode=ParseMode.HTML
            )
            return

    # Terapkan sesi target
    chosen_id = target_session["id"]
    prepare_conversation_for_cli(chosen_id)
    config["active_conversation_id"] = chosen_id
    RESET_NEXT_SESSION = False

    # Jika sesi target memiliki path proyek yang valid di PC, tawarkan / alihkan workspace
    ws_switched_msg = ""
    target_ws = target_session.get("workspace_path")
    if target_ws and Path(target_ws).exists() and Path(target_ws).is_dir():
        current_ws = get_workspace_dir()
        if Path(target_ws).resolve() != current_ws.resolve():
            config["workspace_dir"] = str(Path(target_ws).resolve())
            ws_switched_msg = f"\n• <b>Workspace Dialihkan:</b> <code>{Path(target_ws).name}</code>"

    save_config(config)

    reply = (
        "<b>Sesi Percakapan Berhasil Diaktifkan.</b>\n\n"
        f"• <b>Judul:</b> {html.escape(target_session['title'])}\n"
        f"• <b>ID:</b> <code>{chosen_id}</code>\n"
        f"• <b>Proyek:</b> <code>{target_session['workspace'] or 'Umum'}</code>"
        f"{ws_switched_msg}\n\n"
        "Pesan atau perintah Anda berikutnya (/plan, /goal, chat) akan melanjutkan konteks dari sesi ini."
    )
    await update.effective_message.reply_text(reply, parse_mode=ParseMode.HTML)

async def stop_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    global ACTIVE_PROCESS
    if not await check_auth(update):
        return

    if ACTIVE_PROCESS and ACTIVE_PROCESS.poll() is None:
        try:
            ACTIVE_PROCESS.terminate()
            time.sleep(0.5)
            if ACTIVE_PROCESS.poll() is None:
                ACTIVE_PROCESS.kill()
            ACTIVE_PROCESS = None
            await update.effective_message.reply_text(
                "<b>Proses Antigravity Berhasil Dihentikan.</b>",
                parse_mode=ParseMode.HTML,
            )
        except Exception as e:
            await update.effective_message.reply_text(f"Gagal menghentikan proses: {html.escape(str(e))}")
    else:
        await update.effective_message.reply_text("Tidak ada proses Antigravity yang sedang berjalan saat ini.")

async def screenshot_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await check_auth(update):
        return

    await context.bot.send_chat_action(chat_id=update.effective_chat.id, action=ChatAction.UPLOAD_PHOTO)

    try:
        proc = subprocess.run(
            ["adb", "exec-out", "screencap", "-p"],
            capture_output=True,
            timeout=10,
        )

        if proc.returncode != 0 or not proc.stdout:
            err = proc.stderr.decode("utf-8", errors="ignore")
            await update.effective_message.reply_text(
                f"<b>Gagal mengambil tangkapan layar emulator:</b>\n<code>{html.escape(err or 'Device offline')}</code>\n\n"
                "Pastikan emulator sudah berjalan di PC:\n<code>flutter emulators --launch Medium_Phone</code>",
                parse_mode=ParseMode.HTML,
            )
            return

        waktu = datetime.now().strftime("%H:%M:%S WIB")
        caption = f"<b>Screenshot Emulator Android</b>\nWaktu: <code>{waktu}</code>"

        await context.bot.send_photo(
            chat_id=update.effective_chat.id,
            photo=proc.stdout,
            caption=caption,
            parse_mode=ParseMode.HTML,
        )
    except subprocess.TimeoutExpired:
        await update.effective_message.reply_text("Timeout: ADB tidak merespons dalam 10 detik.")
    except Exception as e:
        await update.effective_message.reply_text(f"Error screenshot: {html.escape(str(e))}")

async def analyze_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await check_auth(update):
        return

    await update.effective_message.reply_text("Menjalankan <code>flutter analyze</code> di PC...", parse_mode=ParseMode.HTML)
    await context.bot.send_chat_action(chat_id=update.effective_chat.id, action=ChatAction.TYPING)

    try:
        proc = subprocess.run(
            ["flutter", "analyze"],
            cwd=get_workspace_dir(),
            capture_output=True,
            text=True,
            timeout=60,
            shell=True,
        )
        out = (proc.stdout + "\n" + proc.stderr).strip()
        if not out:
            out = "Tidak ada output dari flutter analyze."

        reply = f"<b>Hasil Flutter Analyze:</b>\n<pre><code>{html.escape(out)}</code></pre>"
        await split_and_send(update, reply, parse_mode=ParseMode.HTML)
    except subprocess.TimeoutExpired:
        await update.effective_message.reply_text("Timeout: flutter analyze memakan waktu lebih dari 60 detik.")
    except Exception as e:
        await update.effective_message.reply_text(f"Error flutter analyze: {html.escape(str(e))}")

async def git_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await check_auth(update):
        return

    try:
        ws = get_workspace_dir()
        branch_proc = subprocess.run(["git", "branch", "--show-current"], cwd=ws, capture_output=True, text=True)
        branch = branch_proc.stdout.strip()

        status_proc = subprocess.run(["git", "status", "-s"], cwd=ws, capture_output=True, text=True)
        status = status_proc.stdout.strip()
        if not status:
            status = "Semua file bersih (tidak ada perubahan uncommitted)."

        log_proc = subprocess.run(["git", "log", "-1", "--oneline"], cwd=ws, capture_output=True, text=True)
        last_commit = log_proc.stdout.strip()

        reply = (
            f"<b>Git Info ({ws.name})</b>\n"
            f"• <b>Branch:</b> <code>{branch}</code>\n"
            f"• <b>Commit Terakhir:</b> <code>{last_commit}</code>\n\n"
            f"<b>Status Working Tree:</b>\n<pre><code>{html.escape(status)}</code></pre>"
        )
        await update.effective_message.reply_text(reply, parse_mode=ParseMode.HTML)
    except Exception as e:
        await update.effective_message.reply_text(f"Error git: {html.escape(str(e))}")

async def run_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await check_auth(update):
        return

    if not context.args:
        await update.effective_message.reply_text(
            "Format perintah salah.\nContoh: <code>/run git status</code> atau <code>/run dir</code>",
            parse_mode=ParseMode.HTML,
        )
        return

    command_to_run = " ".join(context.args)
    await update.effective_message.reply_text(
        f"Menjalankan: <code>{html.escape(command_to_run)}</code>...",
        parse_mode=ParseMode.HTML
    )
    await context.bot.send_chat_action(chat_id=update.effective_chat.id, action=ChatAction.TYPING)

    try:
        proc = subprocess.run(
            ["powershell", "-Command", command_to_run],
            cwd=get_workspace_dir(),
            capture_output=True,
            text=True,
            timeout=30,
        )
        out = (proc.stdout + "\n" + proc.stderr).strip()
        if not out:
            out = "[Perintah selesai tanpa output]"

        reply = f"<b>Output ({html.escape(command_to_run)}):</b>\n<pre><code>{html.escape(out)}</code></pre>"
        await split_and_send(update, reply, parse_mode=ParseMode.HTML)
    except subprocess.TimeoutExpired:
        await update.effective_message.reply_text("Timeout: Perintah melebihi batas 30 detik.")
    except Exception as e:
        await update.effective_message.reply_text(f"Gagal menjalankan perintah: {html.escape(str(e))}")

async def project_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    global RESET_NEXT_SESSION
    if not await check_auth(update):
        return

    config = load_config()
    current_ws = get_workspace_dir()

    # List available projects in StudioProjects
    if not context.args:
        projects = []
        if STUDIO_PROJECTS_DIR.exists():
            for d in sorted(STUDIO_PROJECTS_DIR.iterdir()):
                if d.is_dir():
                    is_active = (d.resolve() == current_ws.resolve())
                    tag = " <b>(Aktif)</b>" if is_active else ""
                    projects.append(f"• <code>{d.name}</code>{tag}")

        projects_list = "\n".join(projects) if projects else "<i>(Tidak ada folder ditemukan di StudioProjects)</i>"

        reply = (
            "<b>Manajemen Proyek Antigravity</b>\n\n"
            f"<b>Proyek Aktif Saat Ini:</b>\n<code>{current_ws}</code>\n\n"
            f"<b>Daftar Proyek di StudioProjects:</b>\n{projects_list}\n\n"
            "<b>Cara Pindah Proyek:</b>\n"
            "Ketik: <code>/project &lt;nama_folder&gt;</code>\n"
            "Contoh:\n<code>/project deposito</code>\n\n"
            "Atau gunakan path absolut di PC Anda:\n<code>/project D:\\Workspace\\proyek_baru</code>"
        )
        await update.effective_message.reply_text(reply, parse_mode=ParseMode.HTML)
        return

    target_input = " ".join(context.args).strip().strip('"').strip("'")
    target_path = None

    # Check if folder name exists inside StudioProjects
    candidate = STUDIO_PROJECTS_DIR / target_input
    if candidate.exists() and candidate.is_dir():
        target_path = candidate
    else:
        # Check if direct absolute path
        candidate_abs = Path(target_input)
        if candidate_abs.exists() and candidate_abs.is_dir():
            target_path = candidate_abs

    if not target_path:
        await update.effective_message.reply_text(
            f"<b>Folder Proyek Tidak Ditemukan:</b>\n<code>{html.escape(target_input)}</code>\n\n"
            f"Pastikan nama folder ada di <code>{STUDIO_PROJECTS_DIR}</code> atau gunakan path lengkap yang valid.",
            parse_mode=ParseMode.HTML
        )
        return

    # Update config
    config["workspace_dir"] = str(target_path.resolve())
    config["active_conversation_id"] = ""
    save_config(config)

    # Reset Antigravity session so context is not mixed between projects
    RESET_NEXT_SESSION = True

    await update.effective_message.reply_text(
        "<b>Berhasil Berpindah Proyek.</b>\n\n"
        f"• <b>Nama Proyek:</b> <code>{target_path.name}</code>\n"
        f"• <b>Lokasi:</b> <code>{target_path.resolve()}</code>\n\n"
        "Sesi Antigravity di-reset agar bersih. "
        "Semua perintah (/goal, /plan, /git, /analyze, chat) sekarang memproses proyek ini.",
        parse_mode=ParseMode.HTML
    )

async def model_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await check_auth(update):
        return

    config = load_config()
    current_model = config.get("model", "gemini-3.8-flash-high")

    if not context.args:
        model_list = "\n".join([f"• <code>{m}</code> {'<b>(Aktif)</b>' if m == current_model else ''}" for m in AVAILABLE_MODELS])
        reply = (
            "<b>Pengaturan Model Antigravity</b>\n\n"
            f"Model aktif saat ini: <code>{current_model}</code>\n\n"
            f"<b>Daftar Model yang Tersedia:</b>\n{model_list}\n\n"
            "<b>Cara Ganti Model:</b>\n"
            "Ketik: <code>/model &lt;nama_model&gt;</code>\n"
            "Contoh:\n<code>/model claude-sonnet-4-6</code>\natau\n<code>/model gemini-3.8-flash-high</code>"
        )
        await update.effective_message.reply_text(reply, parse_mode=ParseMode.HTML)
        return

    new_model = context.args[0].strip()
    config["model"] = new_model
    try:
        save_config(config)
        await update.effective_message.reply_text(
            f"<b>Model Antigravity Berhasil Diubah.</b>\n\nModel aktif sekarang: <code>{new_model}</code>\n"
            "Antigravity CLI akan menggunakan model ini untuk instruksi selanjutnya.",
            parse_mode=ParseMode.HTML
        )
    except Exception as e:
        await update.effective_message.reply_text(f"Gagal menyimpan model baru: {html.escape(str(e))}")

async def new_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    global RESET_NEXT_SESSION
    if not await check_auth(update):
        return
    RESET_NEXT_SESSION = True
    config = load_config()
    config["active_conversation_id"] = ""
    save_config(config)
    await update.effective_message.reply_text(
        "<b>Sesi Antigravity Direset.</b>\nPesan Anda berikutnya akan memulai percakapan baru dari awal.",
        parse_mode=ParseMode.HTML
    )

# ==================== MESSAGE & EXECUTION HANDLER ====================

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    global ACTIVE_PROCESS, RESET_NEXT_SESSION
    if not await check_auth(update):
        return

    user_text = update.effective_message.text.strip()
    if not user_text:
        return

    # Check if a process is already actively running
    if ACTIVE_PROCESS and ACTIVE_PROCESS.poll() is None:
        await update.effective_message.reply_text(
            "<b>Antigravity sedang mengerjakan tugas sebelumnya.</b>\n\n"
            "Tunggu tugas selesai atau ketik <code>/stop</code> untuk membatalkannya terlebih dahulu.",
            parse_mode=ParseMode.HTML
        )
        return

    if not Path(AGY_EXE).exists():
        await update.effective_message.reply_text(
            f"Executable Antigravity (<code>agy.exe</code>) tidak ditemukan di:\n<code>{AGY_EXE}</code>",
            parse_mode=ParseMode.HTML,
        )
        return

    # Slash Commands mapping
    mode_label = ""
    prompt_to_send = user_text

    # /plan
    if user_text.lower() == "/plan":
        await update.effective_message.reply_text(
            "<b>Mode /plan Antigravity</b>\n\n"
            "Mode ini menyusun rencana aksi bertahap sebelum eksekusi kode.\n\n"
            "<b>Cara Penggunaan:</b>\n"
            "Ketik: <code>/plan &lt;tugas&gt;</code>\nContoh: <code>/plan buatkan alur checkout tagihan</code>",
            parse_mode=ParseMode.HTML
        )
        return
    elif user_text.lower().startswith("/plan "):
        mode_label = " [PLAN]"
        prompt_to_send = (
            f"Rencanakan langkah-langkah kerja (action plan) secara bertahap, terstruktur, "
            f"dan detail untuk: {user_text[6:].strip()}. Langsung paparkan rencana aksinya di sini."
        )

    # /goal
    elif user_text.lower() == "/goal":
        await update.effective_message.reply_text(
            "<b>Mode /goal Antigravity</b>\n\n"
            "Mode ini mengeksekusi instruksi secara otonom tuntas dari awal sampai akhir.\n\n"
            "<b>Cara Penggunaan:</b>\n"
            "Ketik: <code>/goal &lt;tujuan&gt;</code>\nContoh: <code>/goal selesaikan implementasi riwayat tagihan</code>",
            parse_mode=ParseMode.HTML
        )
        return
    elif user_text.lower().startswith("/goal "):
        mode_label = " [GOAL]"
        prompt_to_send = (
            f"Tuntaskan target berikut dari awal sampai akhir secara otonom: {user_text[6:].strip()}. "
            f"Lakukan modifikasi kode yang diperlukan, jalankan verifikasi lint/test, dan laporkan hasilnya."
        )

    # /grill-me
    elif user_text.lower().startswith("/grill-me"):
        mode_label = " [GRILL-ME]"
        topic = user_text[9:].strip() or "arsitektur dan rencana fitur"
        prompt_to_send = (
            f"Lakukan sesi wawancara kritis (Grill-Me) secara interaktif untuk topik: {topic}. "
            f"Ajukan pertanyaan tajam, berikan opsi arsitektur dengan pro/kontra, dan beri rekomendasi terbaik."
        )

    # /learn
    elif user_text.lower().startswith("/learn "):
        mode_label = " [LEARN]"
        rule_content = user_text[7:].strip()
        prompt_to_send = (
            f"Pelajari dan catat aturan/kebiasaan baru berikut ke sistem memori/aturan proyek: {rule_content}."
        )

    # /compact
    elif user_text.lower() == "/compact":
        mode_label = " [COMPACT]"
        prompt_to_send = "Ringkas seluruh konteks dan milestone yang telah dicapai dalam sesi ini ke dalam poin-poin inti."

    config = load_config()
    model_name = config.get("model", "gemini-3.8-flash-high")
    active_cid = config.get("active_conversation_id", "").strip()

    # Determine session title for status UI
    session_title = ""
    if active_cid:
        cur_sess = get_conversation_by_id_or_prefix(active_cid)
        if cur_sess:
            session_title = cur_sess["title"]

    # Kirim initial live status message
    status_header = f"<b>[Antigravity: {model_name}{mode_label}]</b>\n"
    if session_title:
        status_header += f"Sesi: <i>{html.escape(session_title)}</i>\n"
    status_header += "Mempersiapkan tools & membaca konteks repositori..."

    status_msg = await update.effective_message.reply_text(
        status_header,
        parse_mode=ParseMode.HTML
    )

    cmd = [
        AGY_EXE,
        "-p", prompt_to_send,
        "--output-format", "stream-json",
        "--dangerously-skip-permissions",
        "--model", model_name,
    ]

    # Session continuation logic
    if not RESET_NEXT_SESSION:
        if active_cid:
            prepare_conversation_for_cli(active_cid)
            cmd.extend(["--conversation", active_cid])
        else:
            cmd.append("--continue")
    else:
        RESET_NEXT_SESSION = False
        config["active_conversation_id"] = ""
        save_config(config)

    modified_files = set()
    recent_actions = []
    current_action = "Menganalisis permintaan..."
    start_time = time.time()
    last_ui_update = 0
    final_response = ""

    # Start child process
    try:
        proc = subprocess.Popen(
            cmd,
            cwd=get_workspace_dir(),
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
        ACTIVE_PROCESS = proc
    except Exception as e:
        await status_msg.edit_text(f"Gagal menjalankan Antigravity:\n<code>{html.escape(str(e))}</code>", parse_mode=ParseMode.HTML)
        return

    # Helper function to update status message gracefully
    async def update_status_ui(force=False):
        nonlocal last_ui_update
        now = time.time()
        if not force and (now - last_ui_update < 1.8):
            return
        last_ui_update = now
        elapsed = int(now - start_time)
        text = build_status_text(model_name, mode_label, elapsed, current_action, recent_actions, modified_files, session_title)
        try:
            await status_msg.edit_text(text, parse_mode=ParseMode.HTML)
        except Exception:
            pass

    # Read output asynchronously
    loop = asyncio.get_running_loop()

    def read_line():
        return proc.stdout.readline()

    try:
        while True:
            line = await loop.run_in_executor(None, read_line)
            if not line:
                if proc.poll() is not None:
                    break
                await asyncio.sleep(0.1)
                continue

            line = line.strip()
            if not line:
                continue

            try:
                data = json.loads(line)
                event = data.get("event")

                # Tangkap ID sesi dari event init
                if event == "init":
                    new_cid = data.get("conversation_id")
                    if new_cid and new_cid != active_cid:
                        active_cid = new_cid
                        config["active_conversation_id"] = new_cid
                        save_config(config)
                        # Cari judul jika ada
                        sess_meta = get_conversation_by_id_or_prefix(new_cid)
                        if sess_meta:
                            session_title = sess_meta["title"]

                elif event == "step_update":
                    su = data.get("step_update", {})
                    st = su.get("step_type")
                    state = su.get("state")
                    tn = su.get("tool_name")
                    ti = su.get("tool_info", {})
                    params = ti.get("parameters", {})

                    if st == "tool":
                        if tn == "read_file":
                            raw_p = params.get("Path", "")
                            p = get_rel_path(raw_p)
                            act = f"Membaca {p}"
                            current_action = act
                            if state == "DONE" and act not in recent_actions:
                                recent_actions.append(act)

                        elif tn in ["edit_file", "write_file"]:
                            raw_p = params.get("Path", "")
                            p = get_rel_path(raw_p)
                            if p:
                                modified_files.add(p)
                            act = f"Mengedit {p}"
                            current_action = act
                            if state == "DONE" and act not in recent_actions:
                                recent_actions.append(act)

                        elif tn == "run_command":
                            summary = params.get("toolSummary") or params.get("CommandLine", "")[:40]
                            act = f"Menjalankan {summary}"
                            current_action = act
                            if state == "DONE" and act not in recent_actions:
                                recent_actions.append(act)

                        elif tn == "search_files":
                            q = params.get("query", "")
                            act = f"Mencari {q}"
                            current_action = act
                            if state == "DONE" and act not in recent_actions:
                                recent_actions.append(act)

                        else:
                            act = f"Tool {tn}"
                            current_action = act
                            if state == "DONE" and act not in recent_actions:
                                recent_actions.append(act)

                    elif st == "agent_response":
                        current_action = "Menganalisis & menyusun perbaikan..."

                    await update_status_ui()

                elif event == "result":
                    res = data.get("result", {})
                    final_response = res.get("response", "")

            except json.JSONDecodeError:
                pass

        proc.wait()
        total_duration = int(time.time() - start_time)

        # Cek jika proses dihentikan oleh user via /stop
        if proc.returncode != 0 and ACTIVE_PROCESS is None:
            return

        # Check git modified files to make sure nothing was missed
        try:
            git_diff_proc = subprocess.run(
                ["git", "status", "-s"],
                cwd=get_workspace_dir(),
                capture_output=True,
                text=True,
            )
            for g_line in git_diff_proc.stdout.splitlines():
                parts = g_line.strip().split()
                if len(parts) >= 2:
                    modified_files.add(parts[-1].replace("\\", "/"))
        except Exception:
            pass

        # Update final status message
        await status_msg.edit_text(
            f"<b>[Antigravity Selesai]</b> Total waktu: <code>{format_duration(total_duration)}</code>",
            parse_mode=ParseMode.HTML
        )

        # Prepare summary of modified files
        summary_section = ""
        if modified_files:
            summary_section = "\n\n----------------------------------------\n<b>File Dimodifikasi:</b>\n"
            for f in sorted(modified_files):
                summary_section += f"• <code>{f}</code>\n"

        if not final_response.strip():
            final_response = "Tugas telah selesai dieksekusi oleh Antigravity."

        full_output = f"{final_response.strip()}{summary_section}"
        await split_and_send(update, full_output, parse_mode=ParseMode.HTML)

    except Exception as e:
        logger.error(f"Error in stream processing: {e}", exc_info=True)
        await status_msg.edit_text(f"Terjadi kesalahan saat memproses streaming:\n<code>{html.escape(str(e))}</code>", parse_mode=ParseMode.HTML)
    finally:
        ACTIVE_PROCESS = None

def main():
    if not BOT_TOKEN:
        print("Error: bot_token kosong di config.json!")
        sys.exit(1)

    print("=" * 50)
    print("DIAN CATERING ANTIGRAVITY TELEGRAM IDE BRIDGE")
    print(f"Whitelist User ID : {ALLOWED_USER_ID}")
    print(f"Workspace Root   : {get_workspace_dir()}")
    print(f"Antigravity Core  : {AGY_EXE}")
    print("=" * 50)
    print("Bot sedang berjalan... Tekan Ctrl+C untuk berhenti.")

    app = ApplicationBuilder().token(BOT_TOKEN).build()

    # Commands
    app.add_handler(CommandHandler(["start", "help"], start_cmd))
    app.add_handler(CommandHandler(["stop", "cancel"], stop_cmd))
    app.add_handler(CommandHandler(["session", "sessions"], session_cmd))
    app.add_handler(CommandHandler(["project", "cd"], project_cmd))
    app.add_handler(CommandHandler(["ss", "screenshot"], screenshot_cmd))
    app.add_handler(CommandHandler("analyze", analyze_cmd))
    app.add_handler(CommandHandler("git", git_cmd))
    app.add_handler(CommandHandler("run", run_cmd))
    app.add_handler(CommandHandler("model", model_cmd))
    app.add_handler(CommandHandler("new", new_cmd))

    # All text / Slash commands / Goals
    app.add_handler(MessageHandler(filters.TEXT, handle_message))

    app.run_polling()

if __name__ == "__main__":
    main()
