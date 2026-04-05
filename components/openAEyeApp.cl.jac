sv import from ..services.vision { analyze_frame }

def:pub OpenAEyeApp() -> JsxElement {
    has monitoring: bool = False;
    has prox_score: int = 0;
    has prox_label: str = "Clear";
    has prox_history: list = [];
    has scan_count: int = 0;
    has alert_count: int = 0;
    has alert_active: bool = False;
    has alert_time: int = 0;
    has status_text: str = "Tap Start to begin";
    has last_scan_ms: int = 0;

    # ── Proximity helpers ─────────────────────────────────────────

    def record_score(score: int) -> None {
        new_hist = prox_history + [score];
        if len(new_hist) > 5 { new_hist = new_hist[-5:]; }
        prox_history = new_hist;
    }

    def should_alert(score: int) -> bool {
        if score < 3 { return False; }
        if len(prox_history) < 2 { return False; }
        prev = prox_history[:-1];
        for s in prev {
            if s >= 2 { return True; }
        }
        return False;
    }

    # ── Camera + scan logic ───────────────────────────────────────

    async def run_scan() -> None {
        now = Date.now();
        if now - last_scan_ms < 500 { return; }
        last_scan_ms = now;

        video = document.getElementById("oe-video");
        canvas = document.getElementById("oe-canvas");
        if not video or video.readyState < 2 { return; }

        canvas.width = 320;
        canvas.height = 240;
        ctx = canvas.getContext("2d");
        ctx.drawImage(video, 0, 0, 320, 240);
        b64 = canvas.toDataURL("image/jpeg", 0.65).split(",")[1];

        result = await analyze_frame(b64);
        score = result["score"];
        label = result["label"];

        record_score(score);
        scan_count = scan_count + 1;
        prox_score = score;
        prox_label = label;

        # Auto-hide alert after 3 seconds
        if alert_active and Date.now() - alert_time > 3000 {
            alert_active = False;
        }

        if should_alert(score) {
            alert_active = True;
            alert_time = Date.now();
            alert_count = alert_count + 1;
            if not window.speechSynthesis.speaking {
                msg = "Stop now, obstacle ahead";
                if score < 4 { msg = "Stop, obstacle ahead"; }
                utt = SpeechSynthesisUtterance(msg);
                utt.rate = 1.1;
                utt.volume = 1.0;
                window.speechSynthesis.speak(utt);
            }
        } else {
            if score < 3 { alert_active = False; }
        }
    }

    # ── Effect: start/stop scan interval when monitoring changes ─

    can with [monitoring] entry {
        if not monitoring { return; }
        interval_id = setInterval(run_scan, 500);
        def cleanup() -> None {
            clearInterval(interval_id);
        }
        return cleanup;
    }

    # ── Button handlers ───────────────────────────────────────────

    async def handle_start() -> None {
        window.speechSynthesis.speak(SpeechSynthesisUtterance(""));
        status_text = "Requesting camera...";
        stream = await navigator.mediaDevices.getUserMedia({"video": {"facingMode": "user"}, "audio": False});
        video = document.getElementById("oe-video");
        video.srcObject = stream;
        await video.play();
        prox_history = [];
        scan_count = 0;
        alert_count = 0;
        alert_active = False;
        prox_score = 0;
        prox_label = "Clear";
        status_text = "Scanning...";
        monitoring = True;
    }

    def handle_stop() -> None {
        monitoring = False;
        video = document.getElementById("oe-video");
        if video and video.srcObject {
            video.srcObject.getTracks().forEach(lambda t: any -> None { t.stop(); });
            video.srcObject = None;
        }
        prox_history = [];
        alert_active = False;
        prox_score = 0;
        prox_label = "Clear";
        status_text = "Stopped";
    }

    # ── Pre-render computed values ────────────────────────────────

    score_color = "text-emerald-300";
    if prox_score == 1 { score_color = "text-sky-300"; }
    if prox_score == 2 { score_color = "text-amber-300"; }
    if prox_score == 3 { score_color = "text-orange-400"; }
    if prox_score >= 4 { score_color = "text-rose-300"; }

    monitor_badge_cls = "rounded-2xl border border-emerald-400/25 bg-emerald-400/10 px-3 py-2 text-right text-xs font-medium text-emerald-300";
    monitor_badge_txt = "Ready";
    if monitoring {
        monitor_badge_cls = "rounded-2xl border border-rose-400/25 bg-rose-400/10 px-3 py-2 text-right text-xs font-medium text-rose-300";
        monitor_badge_txt = "Live";
    }

    return (
        <main className="min-h-screen bg-[#020817] text-white">
            <div className="mx-auto flex min-h-screen w-full max-w-md flex-col gap-4 px-4 py-5">

                <section className="rounded-[1.75rem] border border-white/10 bg-[#0d1f35] p-5 shadow-lg">
                    <div className="flex items-start justify-between gap-3">
                        <div>
                            <div className="inline-flex items-center gap-2 rounded-full border border-sky-400/25 bg-sky-400/10 px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.24em] text-sky-400">
                                OpenAEye
                            </div>
                            <h1 className="mt-3 text-3xl font-extrabold tracking-tight">
                                AI Navigation
                            </h1>
                            <p className="mt-2 text-sm leading-6 text-slate-400">
                                Front camera · Gemini vision · Voice alerts
                            </p>
                        </div>
                        <div className={monitor_badge_cls}>
                            {monitor_badge_txt}
                        </div>
                    </div>

                    <div className="mt-4 grid grid-cols-3 gap-3 text-center">
                        <div className="rounded-2xl border border-white/8 bg-black/30 px-3 py-3">
                            <p className="text-[10px] uppercase tracking-widest text-slate-500">Status</p>
                            <p className="mt-2 text-sm font-semibold text-slate-200">{status_text}</p>
                        </div>
                        <div className="rounded-2xl border border-white/8 bg-black/30 px-3 py-3">
                            <p className="text-[10px] uppercase tracking-widest text-slate-500">Proximity</p>
                            <p className={"mt-2 text-sm font-semibold " + score_color}>{prox_label}</p>
                        </div>
                        <div className="rounded-2xl border border-white/8 bg-black/30 px-3 py-3">
                            <p className="text-[10px] uppercase tracking-widest text-slate-500">Scans</p>
                            <p className="mt-2 text-sm font-semibold text-slate-200">{scan_count}</p>
                        </div>
                    </div>
                </section>

                <section className="relative overflow-hidden rounded-[1.75rem] border border-white/10 bg-slate-950 shadow-lg" style={{"aspectRatio": "3/4"}}>
                    <video id="oe-video" autoPlay playsInline muted className="w-full h-full object-cover" />
                    <canvas id="oe-canvas" style={{"display": "none"}} />

                    {not monitoring and (
                        <div className="absolute inset-0 flex flex-col items-center justify-center bg-slate-950/90 px-6 text-center">
                            <div className="mb-4 flex h-20 w-20 items-center justify-center rounded-full border border-white/15 bg-white/8 text-4xl">
                                👁
                            </div>
                            <p className="text-base font-semibold">Camera not started</p>
                            <p className="mt-2 max-w-xs text-sm leading-6 text-slate-400">
                                Tap Start monitoring below. Allow camera access when prompted.
                            </p>
                        </div>
                    )}

                    {monitoring and (
                        <div className="absolute left-4 top-4 flex items-center gap-2 rounded-full border border-white/15 bg-slate-950/70 px-3 py-1.5 backdrop-blur">
                            <span className="h-2 w-2 animate-pulse rounded-full bg-emerald-400" />
                            <span className="text-xs font-medium text-emerald-300">Scanning</span>
                        </div>
                    )}

                    <div className="absolute bottom-4 left-4 right-4 rounded-2xl border border-white/10 bg-slate-950/70 p-3 backdrop-blur">
                        <p className="text-xs leading-5 text-slate-300">{status_text}</p>
                    </div>
                </section>

                {alert_active and (
                    <section className="rounded-3xl border border-rose-400/30 bg-rose-400/10 px-5 py-4">
                        <div className="flex items-center gap-3">
                            <div className="relative flex h-10 w-10 shrink-0 items-center justify-center rounded-full border border-rose-400/30 bg-rose-400/15 text-xl">
                                🛑
                            </div>
                            <div>
                                <p className="font-bold text-rose-200">Obstacle Detected</p>
                                <p className="text-sm text-rose-300">Stop, obstacle ahead — proximity: {prox_label}</p>
                            </div>
                        </div>
                    </section>
                )}

                <section className="rounded-[1.75rem] border border-white/10 bg-[#0d1f35] p-4 shadow-lg">
                    <div className="grid grid-cols-2 gap-3">
                        <button
                            className="inline-flex min-h-14 items-center justify-center rounded-2xl bg-sky-500 px-4 py-3 text-sm font-bold text-white transition active:scale-95 active:opacity-80"
                            onClick={handle_start}
                        >
                            Start monitoring
                        </button>
                        <button
                            className="inline-flex min-h-14 items-center justify-center rounded-2xl border border-white/15 bg-black/30 px-4 py-3 text-sm font-semibold text-slate-300 transition active:scale-95 active:opacity-80"
                            onClick={handle_stop}
                        >
                            Stop
                        </button>
                    </div>
                </section>

                <section className="rounded-[1.75rem] border border-white/10 bg-[#0d1f35] p-5 shadow-lg">
                    <p className="text-xs font-semibold uppercase tracking-widest text-slate-500">Detection log</p>
                    <div className="mt-3 space-y-2">
                        <div className="flex justify-between rounded-xl border border-white/8 bg-black/20 px-4 py-2.5 text-sm">
                            <span className="text-slate-400">Total scans</span>
                            <span className="font-semibold">{scan_count}</span>
                        </div>
                        <div className="flex justify-between rounded-xl border border-white/8 bg-black/20 px-4 py-2.5 text-sm">
                            <span className="text-slate-400">Obstacles triggered</span>
                            <span className="font-semibold text-rose-300">{alert_count}</span>
                        </div>
                        <div className="flex justify-between rounded-xl border border-white/8 bg-black/20 px-4 py-2.5 text-sm">
                            <span className="text-slate-400">Current proximity score</span>
                            <span className={"font-semibold " + score_color}>{prox_score} — {prox_label}</span>
                        </div>
                    </div>
                </section>

                <section className="rounded-[1.75rem] border border-white/10 bg-[#0d1f35] p-5 shadow-lg">
                    <p className="text-xs font-semibold uppercase tracking-widest text-slate-500">Disclaimer</p>
                    <p className="mt-3 text-xs leading-6 text-slate-500">
                        OpenAEye is a prototype. Not a certified safety device. Always verify surroundings manually. AI responses may be incorrect.
                    </p>
                </section>

                <div className="pb-8" />
            </div>
        </main>
    );
}
