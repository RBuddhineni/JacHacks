def format_percent(value: int) -> str {
    safe_value = value;
    if safe_value < 0 { safe_value = 0; }
    if safe_value > 100 { safe_value = 100; }
    return str(safe_value) + "%";
}

def:pub OpenAEyeApp() -> JsxElement {
    has monitoring: bool = False;
    has spoken_alerts: bool = True;
    has vibration_alerts: bool = True;
    has prototype_ai_ready: bool = True;
    has camera_status: str = "Rear camera will request access when you tap Start monitoring.";
    has monitor_status: str = "Idle";
    has hazard_level: str = "Low";
    has hazard_reason: str = "Point your phone at a chair or walkway, then tap Start.";
    has alert_banner: str = "";
    has brightness_score: int = 42;
    has motion_score: int = 18;
    has change_score: int = 24;
    has cycle_count: int = 0;
    has last_alert_at: str = "No alerts yet";
    has permission_hint: str = "Best on iPhone Safari using the rear camera.";
    has preview_label: str = "Camera preview placeholder";

    def handle_start() -> None {
        monitoring = True;
        monitor_status = "Starting";
        camera_status = "Requesting rear camera access… If Safari asks, choose Allow.";
        permission_hint = "Tip: if the front camera opens, switch to the back camera in Safari controls.";
        preview_label = "Live camera preview should appear here after permission is granted.";
        cycle_count = cycle_count + 1;
        brightness_score = 58;
        motion_score = 34;
        change_score = 41;
        hazard_level = "Watching";
        hazard_reason = "Prototype monitoring is active. Move a chair slowly to simulate scene change.";
        alert_banner = "";
    }

    def handle_stop() -> None {
        monitoring = False;
        monitor_status = "Stopped";
        camera_status = "Camera stopped. Tap Start monitoring to request access again.";
        hazard_level = "Low";
        hazard_reason = "Monitoring paused. No active camera analysis running.";
        alert_banner = "";
        preview_label = "Preview paused";
    }

    def handle_toggle_spoken() -> None {
        spoken_alerts = not spoken_alerts;
    }

    def handle_toggle_vibration() -> None {
        vibration_alerts = not vibration_alerts;
    }

    def handle_test_alert() -> None {
        alert_banner = "Test alert triggered — obstacle detected in prototype mode.";
        hazard_level = "High";
        hazard_reason = "Manual test path fired. Spoken/vibration alerts would trigger on device.";
        last_alert_at = "Just now";
        motion_score = 82;
        change_score = 88;
        brightness_score = 63;
    }

    def handle_simulate_scan() -> None {
        cycle_count = cycle_count + 1;
        if monitoring {
            if cycle_count % 3 == 0 {
                hazard_level = "Elevated";
                hazard_reason = "Large scene change detected. Try moving the chair closer to the camera.";
                motion_score = 67;
                change_score = 74;
                brightness_score = 49;
                alert_banner = "Prototype noticed a stronger scene change. Verify surroundings manually.";
                last_alert_at = "Recent simulated scan";
            } else {
                hazard_level = "Watching";
                hazard_reason = "Scene looks stable. Continue moving the chair to test detection sensitivity.";
                motion_score = 36;
                change_score = 43;
                brightness_score = 57;
                alert_banner = "";
            }
            monitor_status = "Monitoring";
            camera_status = "Camera active in prototype mode. Rear camera access should remain on while monitoring.";
        } else {
            hazard_reason = "Start monitoring first to run simulated hazard scans.";
        }
    }

    ai_status_label = "AI vision ready next";
    if not prototype_ai_ready { ai_status_label = "Prototype only"; }

    spoken_cls = "rounded-full bg-emerald-400/15 px-3 py-1 text-xs font-semibold text-emerald-300";
    if not spoken_alerts { spoken_cls = "rounded-full bg-slate-700/60 px-3 py-1 text-xs font-semibold text-slate-300"; }
    spoken_lbl = "On";
    if not spoken_alerts { spoken_lbl = "Off"; }

    vibration_cls = "rounded-full bg-emerald-400/15 px-3 py-1 text-xs font-semibold text-emerald-300";
    if not vibration_alerts { vibration_cls = "rounded-full bg-slate-700/60 px-3 py-1 text-xs font-semibold text-slate-300"; }
    vibration_lbl = "On";
    if not vibration_alerts { vibration_lbl = "Off"; }

    return (
        <main className="min-h-screen bg-background text-foreground">
            <div className="mx-auto flex min-h-screen w-full max-w-md flex-col gap-4 px-4 py-5 sm:max-w-lg">
                <section className="rounded-[1.75rem] border border-border bg-card/95 p-5 shadow-card backdrop-blur">
                    <div className="flex items-start justify-between gap-3">
                        <div>
                            <div className="inline-flex items-center gap-2 rounded-full border border-primary/25 bg-primary/10 px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.24em] text-primary">
                                OpenAEye
                            </div>
                            <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-foreground">
                                Mobile hazard monitor
                            </h1>
                            <p className="mt-2 text-sm leading-6 text-muted-foreground">
                                Rear-camera prototype for phone testing with a chair, hallway, or obstacle course.
                            </p>
                        </div>
                        <div className="rounded-2xl border border-emerald-400/25 bg-emerald-400/10 px-3 py-2 text-right text-xs font-medium text-emerald-300">
                            {ai_status_label}
                        </div>
                    </div>

                    <div className="mt-4 grid grid-cols-3 gap-3 text-center">
                        <div className="rounded-2xl border border-border bg-background/70 px-3 py-3 shadow-soft">
                            <p className="text-[11px] uppercase tracking-[0.2em] text-muted-foreground">Status</p>
                            <p className="mt-2 text-sm font-semibold text-foreground">{monitor_status}</p>
                        </div>
                        <div className="rounded-2xl border border-border bg-background/70 px-3 py-3 shadow-soft">
                            <p className="text-[11px] uppercase tracking-[0.2em] text-muted-foreground">Hazard</p>
                            <p className="mt-2 text-sm font-semibold text-foreground">{hazard_level}</p>
                        </div>
                        <div className="rounded-2xl border border-border bg-background/70 px-3 py-3 shadow-soft">
                            <p className="text-[11px] uppercase tracking-[0.2em] text-muted-foreground">Scans</p>
                            <p className="mt-2 text-sm font-semibold text-foreground">{cycle_count}</p>
                        </div>
                    </div>
                </section>

                <section className="overflow-hidden rounded-[1.75rem] border border-border bg-card shadow-card">
                    <div className="relative aspect-[3/4] w-full bg-gradient-to-b from-sky-500/20 via-slate-950 to-slate-950">
                        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,rgba(103,232,249,0.18),transparent_35%)]" />
                        <div className="absolute inset-0 flex flex-col items-center justify-center px-6 text-center">
                            <div className="mb-4 flex h-20 w-20 items-center justify-center rounded-full border border-white/15 bg-white/8 text-3xl shadow-soft">
                                📷
                            </div>
                            <p className="text-base font-semibold text-white">{preview_label}</p>
                            <p className="mt-2 max-w-xs text-sm leading-6 text-slate-300">
                                Tap Start monitoring on your phone to request camera permission and begin prototype checks.
                            </p>
                        </div>
                        <div className="absolute left-4 right-4 top-4 flex items-center justify-between gap-3">
                            <div className="rounded-full border border-white/15 bg-slate-950/55 px-3 py-1.5 text-xs font-medium text-slate-200">
                                {camera_status}
                            </div>
                        </div>
                        <div className="absolute bottom-4 left-4 right-4 rounded-2xl border border-white/10 bg-slate-950/60 p-3 text-left text-xs text-slate-200 backdrop-blur">
                            <p className="font-semibold text-white">Phone testing note</p>
                            <p className="mt-1 leading-5 text-slate-300">
                                This build is frontend-first. Real AI vision can plug in later; today it focuses on camera access, simulated scans, and manual alert testing.
                            </p>
                        </div>
                    </div>
                </section>

                {alert_banner and (
                    <section className="rounded-3xl border border-rose-400/30 bg-rose-400/10 px-4 py-4 text-sm text-rose-100 shadow-soft">
                        <p className="font-semibold">Alert</p>
                        <p className="mt-1 leading-6">{alert_banner}</p>
                    </section>
                )}

                <section className="rounded-[1.75rem] border border-border bg-card p-4 shadow-card">
                    <div className="grid grid-cols-2 gap-3">
                        <button
                            className="inline-flex min-h-12 items-center justify-center rounded-2xl bg-primary px-4 py-3 text-sm font-semibold text-primary-foreground transition hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-primary"
                            onClick={handle_start}
                        >
                            Start monitoring
                        </button>
                        <button
                            className="inline-flex min-h-12 items-center justify-center rounded-2xl border border-border bg-background px-4 py-3 text-sm font-semibold text-foreground transition hover:bg-card-hover focus:outline-none focus:ring-2 focus:ring-primary"
                            onClick={handle_stop}
                        >
                            Stop
                        </button>
                        <button
                            className="inline-flex min-h-12 items-center justify-center rounded-2xl border border-amber-300/30 bg-amber-300/10 px-4 py-3 text-sm font-semibold text-amber-100 transition hover:bg-amber-300/15 focus:outline-none focus:ring-2 focus:ring-amber-300"
                            onClick={handle_simulate_scan}
                        >
                            Simulate scan
                        </button>
                        <button
                            className="inline-flex min-h-12 items-center justify-center rounded-2xl border border-rose-300/30 bg-rose-300/10 px-4 py-3 text-sm font-semibold text-rose-100 transition hover:bg-rose-300/15 focus:outline-none focus:ring-2 focus:ring-rose-300"
                            onClick={handle_test_alert}
                        >
                            Test alert
                        </button>
                    </div>

                    <div className="mt-4 grid gap-3">
                        <button
                            className="flex items-center justify-between rounded-2xl border border-border bg-background/70 px-4 py-3 text-left transition hover:bg-card-hover focus:outline-none focus:ring-2 focus:ring-primary"
                            onClick={handle_toggle_spoken}
                        >
                            <span>
                                <span className="block text-sm font-semibold text-foreground">Spoken alerts</span>
                                <span className="block text-xs text-muted-foreground">Use speech output when a hazard is detected.</span>
                            </span>
                            <span className={spoken_cls}>
                                {spoken_lbl}
                            </span>
                        </button>

                        <button
                            className="flex items-center justify-between rounded-2xl border border-border bg-background/70 px-4 py-3 text-left transition hover:bg-card-hover focus:outline-none focus:ring-2 focus:ring-primary"
                            onClick={handle_toggle_vibration}
                        >
                            <span>
                                <span className="block text-sm font-semibold text-foreground">Vibration alerts</span>
                                <span className="block text-xs text-muted-foreground">Useful for pocket or noisy-environment testing.</span>
                            </span>
                            <span className={vibration_cls}>
                                {vibration_lbl}
                            </span>
                        </button>
                    </div>
                </section>

                <section className="grid grid-cols-3 gap-3">
                    <div className="rounded-3xl border border-border bg-card p-4 shadow-soft">
                        <p className="text-[11px] uppercase tracking-[0.2em] text-muted-foreground">Brightness</p>
                        <p className="mt-3 text-2xl font-bold text-foreground">{format_percent(brightness_score)}</p>
                    </div>
                    <div className="rounded-3xl border border-border bg-card p-4 shadow-soft">
                        <p className="text-[11px] uppercase tracking-[0.2em] text-muted-foreground">Motion</p>
                        <p className="mt-3 text-2xl font-bold text-foreground">{format_percent(motion_score)}</p>
                    </div>
                    <div className="rounded-3xl border border-border bg-card p-4 shadow-soft">
                        <p className="text-[11px] uppercase tracking-[0.2em] text-muted-foreground">Change</p>
                        <p className="mt-3 text-2xl font-bold text-foreground">{format_percent(change_score)}</p>
                    </div>
                </section>

                <section className="rounded-[1.75rem] border border-border bg-card p-5 shadow-card">
                    <div className="flex items-center justify-between gap-3">
                        <div>
                            <p className="text-xs font-semibold uppercase tracking-[0.24em] text-muted-foreground">Status cards</p>
                            <h2 className="mt-2 text-xl font-bold text-foreground">Prototype readiness</h2>
                        </div>
                        <div className="rounded-full border border-primary/20 bg-primary/10 px-3 py-1 text-xs font-semibold text-primary">
                            Mobile-first
                        </div>
                    </div>

                    <div className="mt-4 space-y-3">
                        <div className="rounded-2xl border border-border bg-background/70 p-4">
                            <p className="text-sm font-semibold text-foreground">Detection summary</p>
                            <p className="mt-1 text-sm leading-6 text-muted-foreground">{hazard_reason}</p>
                        </div>
                        <div className="rounded-2xl border border-border bg-background/70 p-4">
                            <p className="text-sm font-semibold text-foreground">Permission hint</p>
                            <p className="mt-1 text-sm leading-6 text-muted-foreground">{permission_hint}</p>
                        </div>
                        <div className="rounded-2xl border border-border bg-background/70 p-4">
                            <p className="text-sm font-semibold text-foreground">Last alert</p>
                            <p className="mt-1 text-sm leading-6 text-muted-foreground">{last_alert_at}</p>
                        </div>
                    </div>
                </section>

                <section className="rounded-[1.75rem] border border-border bg-card p-5 shadow-card">
                    <p className="text-xs font-semibold uppercase tracking-[0.24em] text-muted-foreground">Disclaimer</p>
                    <p className="mt-3 text-sm leading-6 text-muted-foreground">
                        OpenAEye is a prototype and not a certified medical, mobility, or safety device. Always verify surroundings manually. Camera access, speech, vibration, and future AI vision features may behave differently across browsers and devices.
                    </p>
                </section>
            </div>
        </main>
    );
}
