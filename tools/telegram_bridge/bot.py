import os
import sys
import json
import time
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

# Base Directories
CURRENT_DIR = Path(__file__).resolve().parent
WORKSPACE_DIR = CURRENT_DIR.parent.parent
CONFIG_PATH = CURRENT_DIR / "config.json"
AGY_EXE = r"C:\Users\jundi\.gemini\bin\agy.exe"

AVAILABLE_MODELS = [
    "gemini-3.8-flash-high",
    "claude-sonnet-4-6",
    "claude-opus-4-6-thinking",
    "gpt-oss-120b-medium",
    "gemini-3.8-flash-medium",
    "gemini-3.8-flash-low",
]

def load_config():
    if not CONFIG_PATH.exists():
        raise FileNotFoundError(f"Config file not found at {CONFIG_PATH}")
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        return json.load(f)

CONFIG = load_config()
BOT_TOKEN = CONFIG.get("bot_token", "").strip()
ALLOWED_USER_ID = int(CONFIG.get("allowed_user_id", 0))

# Global tracking for active process and reset state
ACTIVE_PROCESS = None
ACTIVE_PROCESS_LOCK = asyncio.Lock()
RESET_NEXT_SESSION = False

def is_authorized(user_id: int) -> bool:
    return user_id == ALLOWED_USER_ID

async def check_auth(update: Update) -> bool:
    user = update.effective_user
    if not user or not is_authorized(user.id):
        logger.warning(f"Unauthorized access attempt by user {user.id if user else 'Unknown'}")
        if update.effective_message:
            await update.effective_message.reply_text(
                f"⛔ Akses Ditolak.\nID Akun Anda ({user.id if user else 'N/A'}) belum diizinkan mengontrol PC ini."
            )
        return False
    return True

async def split_and_send(update: Update, text: str, parse_mode=None):
    """Kirim pesan panjang dengan membaginya jika melebihi limit Telegram (4096 karakter)."""
    max_len = 3900
    if len(text) <= max_len:
        try:
            await update.effective_message.reply_text(text, parse_mode=parse_mode)
        except Exception:
            await update.effective_message.reply_text(text)
        return

    parts = [text[i:i + max_len] for i in range(0, len(text), max_len)]
    for part in parts:
        try:
            await update.effective_message.reply_text(part, parse_mode=parse_mode)
        except Exception:
            await update.effective_message.reply_text(part)

def get_rel_path(raw_path: str) -> str:
    if not raw_path:
        return ""
    try:
        p = Path(raw_path)
        if p.is_relative_to(WORKSPACE_DIR):
            return str(p.relative_to(WORKSPACE_DIR)).replace("\\", "/")
        return p.name
    except Exception:
        return Path(raw_path).name

# ==================== COMMAND HANDLERS ====================

async def start_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await check_auth(update):
        return

    config = load_config()
    current_model = config.get("model", "gemini-3.8-flash-high")

    msg = (
        "🚀 *Antigravity Telegram IDE Bridge*\n\n"
        "Antarmuka langsung ke mesin **Google Antigravity CLI** dengan pantauan progres *live* per langkah:\n\n"
        f"🧠 *Model Aktif*: `{current_model}`\n\n"
        "📌 *Perintah Developer & Kontrol:*\n"
        "• 🛑 `/stop` atau `/cancel`\n"
        "  └ Hentikan proses eksekusi Antigravity yang sedang berjalan seketika.\n\n"
        "• 📸 `/ss` atau `/screenshot`\n"
        "  └ Ambil tangkapan layar emulator Android aktif di PC.\n\n"
        "• 🧠 `/model` atau `/model <nama>`\n"
        "  └ Ganti model AI (Claude, GPT, Gemini Flash/Opus).\n\n"
        "• 🔄 `/new`\n"
        "  └ Reset percakapan untuk memulai topik baru dari awal.\n\n"
        "• 🔍 `/analyze` & 🌿 `/git`\n"
        "  └ Cek linter flutter analyze & status perubahan git.\n\n"
        "⚡ *Slash Commands Antigravity:*\n"
        "• `/goal <tugas>` : Eksekusi otonom menyeluruh sampai selesai.\n"
        "• `/plan <tugas>` : Susun rencana aksi bertahap sebelum eksekusi.\n"
        "• `/grill-me <topik>` : Diskusi kritis/interview arsitektur fitur.\n"
        "• `/learn <pola>` : Simpan aturan/pembelajaran baru ke sistem.\n"
        "• `/compact` : Ringkas riwayat percakapan.\n\n"
        "💬 *Kirim Pesan Biasa*\n"
        "└ Tanyakan apa saja atau instruksikan perbaikan kode secara langsung!\n"
    )
    await update.effective_message.reply_text(msg, parse_mode=ParseMode.MARKDOWN)

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
                "🛑 *Proses Antigravity Berhasil Dihentikan!*",
                parse_mode=ParseMode.MARKDOWN
            )
        except Exception as e:
            await update.effective_message.reply_text(f"❌ Gagal menghentikan proses: {str(e)}")
    else:
        await update.effective_message.reply_text(
            "ℹ️ Tidak ada proses Antigravity yang sedang berjalan saat ini."
        )

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
                f"❌ Gagal mengambil tangkapan layar emulator:\n`{err or 'Device offline'}`\n\n"
                "Pastikan emulator sudah berjalan di PC:\n`flutter emulators --launch Medium_Phone`",
                parse_mode=ParseMode.MARKDOWN,
            )
            return

        waktu = datetime.now().strftime("%H:%M:%S WIB")
        caption = f"📸 *Screenshot Emulator Android*\n🕒 {waktu}"

        await context.bot.send_photo(
            chat_id=update.effective_chat.id,
            photo=proc.stdout,
            caption=caption,
            parse_mode=ParseMode.MARKDOWN,
        )
    except subprocess.TimeoutExpired:
        await update.effective_message.reply_text("⏱️ Timeout: ADB tidak merespons dalam 10 detik.")
    except Exception as e:
        await update.effective_message.reply_text(f"❌ Error screenshot: {str(e)}")

async def analyze_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await check_auth(update):
        return

    await update.effective_message.reply_text("⏳ Menjalankan `flutter analyze` di PC...")
    await context.bot.send_chat_action(chat_id=update.effective_chat.id, action=ChatAction.TYPING)

    try:
        proc = subprocess.run(
            ["flutter", "analyze"],
            cwd=WORKSPACE_DIR,
            capture_output=True,
            text=True,
            timeout=60,
            shell=True,
        )
        out = (proc.stdout + "\n" + proc.stderr).strip()
        if not out:
            out = "Tidak ada output dari flutter analyze."

        reply = f"🔍 *Hasil Flutter Analyze:*\n```\n{out}\n```"
        await split_and_send(update, reply, parse_mode=ParseMode.MARKDOWN)
    except subprocess.TimeoutExpired:
        await update.effective_message.reply_text("⏱️ Timeout: `flutter analyze` memakan waktu lebih dari 60 detik.")
    except Exception as e:
        await update.effective_message.reply_text(f"❌ Error flutter analyze: {str(e)}")

async def git_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await check_auth(update):
        return

    try:
        branch_proc = subprocess.run(["git", "branch", "--show-current"], cwd=WORKSPACE_DIR, capture_output=True, text=True)
        branch = branch_proc.stdout.strip()

        status_proc = subprocess.run(["git", "status", "-s"], cwd=WORKSPACE_DIR, capture_output=True, text=True)
        status = status_proc.stdout.strip()
        if not status:
            status = "Semua file bersih (tidak ada perubahan uncommitted)."

        log_proc = subprocess.run(["git", "log", "-1", "--oneline"], cwd=WORKSPACE_DIR, capture_output=True, text=True)
        last_commit = log_proc.stdout.strip()

        reply = (
            f"🌿 *Git Info*\n"
            f"• *Branch*: `{branch}`\n"
            f"• *Commit Terakhir*: `{last_commit}`\n\n"
            f"📝 *Status Working Tree:*\n```\n{status}\n```"
        )
        await update.effective_message.reply_text(reply, parse_mode=ParseMode.MARKDOWN)
    except Exception as e:
        await update.effective_message.reply_text(f"❌ Error git: {str(e)}")

async def run_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await check_auth(update):
        return

    if not context.args:
        await update.effective_message.reply_text(
            "Format perintah salah.\nContoh: `/run git status` atau `/run dir`",
            parse_mode=ParseMode.MARKDOWN,
        )
        return

    command_to_run = " ".join(context.args)
    await update.effective_message.reply_text(f"⚡ Menjalankan: `{command_to_run}`...", parse_mode=ParseMode.MARKDOWN)
    await context.bot.send_chat_action(chat_id=update.effective_chat.id, action=ChatAction.TYPING)

    try:
        proc = subprocess.run(
            ["powershell", "-Command", command_to_run],
            cwd=WORKSPACE_DIR,
            capture_output=True,
            text=True,
            timeout=30,
        )
        out = (proc.stdout + "\n" + proc.stderr).strip()
        if not out:
            out = "[Perintah selesai tanpa output]"

        reply = f"💻 *Output ({command_to_run}):*\n```\n{out}\n```"
        await split_and_send(update, reply, parse_mode=ParseMode.MARKDOWN)
    except subprocess.TimeoutExpired:
        await update.effective_message.reply_text("⏱️ Timeout: Perintah melebihi batas 30 detik.")
    except Exception as e:
        await update.effective_message.reply_text(f"❌ Gagal menjalankan perintah: {str(e)}")

async def model_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await check_auth(update):
        return

    config = load_config()
    current_model = config.get("model", "gemini-3.8-flash-high")

    if not context.args:
        model_list = "\n".join([f"• `{m}` {'*(Aktif)*' if m == current_model else ''}" for m in AVAILABLE_MODELS])
        reply = (
            f"🧠 *Pengaturan Model Antigravity*\n\n"
            f"Model aktif saat ini: `{current_model}`\n\n"
            f"📋 *Daftar Model yang Tersedia:*\n{model_list}\n\n"
            f"💡 *Cara Ganti Model:*\n"
            f"Ketik: `/model <nama_model>`\n"
            f"Contoh:\n`/model claude-sonnet-4-6`\natau\n`/model gemini-3.8-flash-high`"
        )
        await update.effective_message.reply_text(reply, parse_mode=ParseMode.MARKDOWN)
        return

    new_model = context.args[0].strip()
    config["model"] = new_model
    try:
        with open(CONFIG_PATH, "w", encoding="utf-8") as f:
            json.dump(config, f, indent=2)
        await update.effective_message.reply_text(
            f"✅ *Model Antigravity Berhasil Diubah!* 🔄\n\nModel aktif sekarang: `{new_model}`\n"
            f"Antigravity CLI akan menggunakan model ini untuk instruksi Anda selanjutnya.",
            parse_mode=ParseMode.MARKDOWN
        )
    except Exception as e:
        await update.effective_message.reply_text(f"❌ Gagal menyimpan model baru: {str(e)}")

async def new_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    global RESET_NEXT_SESSION
    if not await check_auth(update):
        return
    RESET_NEXT_SESSION = True
    await update.effective_message.reply_text(
        "🔄 *Sesi Antigravity Direset!*\nPesan Anda berikutnya akan memulai percakapan baru dari awal.",
        parse_mode=ParseMode.MARKDOWN
    )

# ==================== LIVE STREAMING & PROGRESS HANDLER ====================

def format_duration(seconds: int) -> str:
    m, s = divmod(seconds, 60)
    if m > 0:
        return f"{m}m {s}s"
    return f"{s}s"

def build_status_text(model_name: str, mode_label: str, elapsed_sec: int, current_action: str, recent_actions: list, modified_files: set) -> str:
    dur_str = format_duration(elapsed_sec)
    
    text = f"🤖 *Antigravity ({model_name}){mode_label}*\n"
    text += f"⏱️ *Durasi:* `{dur_str}`\n"
    text += "─────────────────────────────\n"
    text += f"⏳ *Sedang:* {current_action}\n\n"

    if recent_actions:
        text += "📋 *Langkah Terakhir:*\n"
        for act in recent_actions[-3:]:
            text += f"• {act}\n"
        text += "\n"

    if modified_files:
        text += f"📁 *File Dimodifikasi ({len(modified_files)}):*\n"
        for f in list(modified_files)[-5:]:
            text += f"• `{f}`\n"
        if len(modified_files) > 5:
            text += f"• _...dan {len(modified_files) - 5} file lainnya_\n"
        text += "\n"

    text += "💡 *Ketik `/stop` untuk membatalkan proses kapan saja.*"
    return text

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
            "⚠️ *Antigravity sedang mengerjakan tugas sebelumnya!*\n\n"
            "Tunggu tugas selesai atau ketik `/stop` untuk membatalkannya terlebih dahulu.",
            parse_mode=ParseMode.MARKDOWN
        )
        return

    if not Path(AGY_EXE).exists():
        await update.effective_message.reply_text(
            f"❌ Executable Antigravity (`agy.exe`) tidak ditemukan di:\n`{AGY_EXE}`",
            parse_mode=ParseMode.MARKDOWN,
        )
        return

    # Slash Commands mapping
    mode_label = ""
    prompt_to_send = user_text

    # /plan
    if user_text.lower() == "/plan":
        await update.effective_message.reply_text(
            "📋 *Mode /plan Antigravity*\n\n"
            "Mode ini menyusun rencana aksi bertahap sebelum eksekusi kode.\n\n"
            "💡 *Cara Penggunaan:*\n"
            "Ketik `/plan <tugas>`\nContoh: `/plan buatkan alur pembayaran tagihan`",
            parse_mode=ParseMode.MARKDOWN
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
            "🎯 *Mode /goal Antigravity*\n\n"
            "Mode ini mengeksekusi instruksi secara otonom tuntas dari awal sampai akhir.\n\n"
            "💡 *Cara Penggunaan:*\n"
            "Ketik `/goal <tujuan>`\nContoh: `/goal selesaikan implementasi riwayat tagihan`",
            parse_mode=ParseMode.MARKDOWN
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

    # Kirim initial live status message
    status_msg = await update.effective_message.reply_text(
        f"🤖 *Antigravity ({model_name}){mode_label} sedang memulai...*\n"
        "⏳ _Mempersiapkan tools & membaca konteks repositori..._",
        parse_mode=ParseMode.MARKDOWN
    )

    cmd = [
        AGY_EXE,
        "-p", prompt_to_send,
        "--output-format", "stream-json",
        "--dangerously-skip-permissions",
        "--model", model_name,
    ]

    if not RESET_NEXT_SESSION:
        cmd.append("--continue")
    else:
        RESET_NEXT_SESSION = False

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
            cwd=WORKSPACE_DIR,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
        ACTIVE_PROCESS = proc
    except Exception as e:
        await status_msg.edit_text(f"❌ Gagal menjalankan Antigravity:\n`{str(e)}`")
        return

    # Helper function to update status message gracefully
    async def update_status_ui(force=False):
        nonlocal last_ui_update
        now = time.time()
        if not force and (now - last_ui_update < 1.8):
            return
        last_ui_update = now
        elapsed = int(now - start_time)
        text = build_status_text(model_name, mode_label, elapsed, current_action, recent_actions, modified_files)
        try:
            await status_msg.edit_text(text, parse_mode=ParseMode.MARKDOWN)
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

                if event == "step_update":
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
                            act = f"📖 Membaca `{p}`"
                            current_action = act
                            if state == "DONE" and act not in recent_actions:
                                recent_actions.append(act)

                        elif tn in ["edit_file", "write_file"]:
                            raw_p = params.get("Path", "")
                            p = get_rel_path(raw_p)
                            if p:
                                modified_files.add(p)
                            act = f"✏️ Mengedit `{p}`"
                            current_action = act
                            if state == "DONE" and act not in recent_actions:
                                recent_actions.append(act)

                        elif tn == "run_command":
                            summary = params.get("toolSummary") or params.get("CommandLine", "")[:40]
                            act = f"⚡ Menjalankan `{summary}`"
                            current_action = act
                            if state == "DONE" and act not in recent_actions:
                                recent_actions.append(act)

                        elif tn == "search_files":
                            q = params.get("query", "")
                            act = f"🔍 Mencari `{q}`"
                            current_action = act
                            if state == "DONE" and act not in recent_actions:
                                recent_actions.append(act)

                        else:
                            act = f"⚙️ Tool `{tn}`"
                            current_action = act
                            if state == "DONE" and act not in recent_actions:
                                recent_actions.append(act)

                    elif st == "agent_response":
                        current_action = "🤔 Menganalisis & merumuskan kode..."

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
            # Stopped intentionally
            return

        # Check git modified files to make sure nothing was missed
        try:
            git_diff_proc = subprocess.run(
                ["git", "status", "-s"],
                cwd=WORKSPACE_DIR,
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
            f"✅ *Antigravity Telah Selesai!* (Total Waktu: `{format_duration(total_duration)}`)",
            parse_mode=ParseMode.MARKDOWN
        )

        # Prepare summary of modified files
        summary_section = ""
        if modified_files:
            summary_section = "\n\n─────────────────────────────\n📁 *File & Folder yang Telah Dimodifikasi:*\n"
            for f in sorted(modified_files):
                summary_section += f"• `{f}`\n"

        if not final_response.strip():
            final_response = "Tugas telah selesai dieksekusi oleh Antigravity."

        full_output = f"{final_response.strip()}{summary_section}"
        await split_and_send(update, full_output)

    except Exception as e:
        logger.error(f"Error in stream processing: {e}", exc_info=True)
        await status_msg.edit_text(f"❌ Terjadi kesalahan saat memproses streaming:\n`{str(e)}`")
    finally:
        ACTIVE_PROCESS = None

def main():
    if not BOT_TOKEN:
        print("Error: bot_token kosong di config.json!")
        sys.exit(1)

    print("=" * 50)
    print("🚀 DIAN CATERING ANTIGRAVITY TELEGRAM IDE BRIDGE")
    print(f"👤 Whitelist User ID : {ALLOWED_USER_ID}")
    print(f"📂 Workspace Root   : {WORKSPACE_DIR}")
    print(f"🛠️ Antigravity Core  : {AGY_EXE}")
    print("=" * 50)
    print("Bot sedang berjalan... Tekan Ctrl+C untuk berhenti.")

    app = ApplicationBuilder().token(BOT_TOKEN).build()

    # Commands
    app.add_handler(CommandHandler(["start", "help"], start_cmd))
    app.add_handler(CommandHandler(["stop", "cancel"], stop_cmd))
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
