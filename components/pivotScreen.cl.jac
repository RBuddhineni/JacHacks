def PivotScreen() -> JsxElement {
    return <main className="min-h-screen bg-background text-foreground">
        <section className="mx-auto flex min-h-screen max-w-3xl flex-col items-center justify-center px-6 py-16 text-center">
            <div className="rounded-full border border-border bg-card px-4 py-1 text-sm font-medium text-muted-foreground shadow-soft">
                Pivot mode
            </div>
            <h1 className="mt-6 text-4xl font-semibold tracking-tight sm:text-5xl">
                Ready for the next build.
            </h1>
            <p className="mt-4 max-w-xl text-base leading-7 text-muted-foreground sm:text-lg">
                The previous app has been cleared out and replaced with a clean starter screen.
            </p>
        </section>
    </main>;
}
