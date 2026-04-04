sv import from ..services.relist { run_relist_agent }

def format_currency(value: float) -> str {
    return "$" + str(round(value, 2));
}

def:pub RelistDashboard() -> JsxElement {
    has item_input: str = "used Nike Dunk Low size 10, worn twice, white black colorway";
    has loading: bool = False;
    has current_step: str = "Template mode — no API keys required yet";
    has result: dict = {};

    async can with entry {
        result = await run_relist_agent(item_input, False);
    }

    async def submit_demo() -> None {
        loading = True;
        current_step = "Running autonomous resale pipeline...";
        result = await run_relist_agent(item_input, False);
        current_step = "Template mode complete — connect Anthropic + eBay keys later";
        loading = False;
    }

    return (
        <main className="min-h-screen px-6 py-10 text-slate-100 md:px-10 xl:px-16">
            <div className="mx-auto flex max-w-7xl flex-col gap-8">
                <section className="grid gap-6 xl:grid-cols-2">
                    <div className="rounded-3xl border border-white/10 bg-white/6 p-8 shadow-[var(--shadow-panel)] backdrop-blur-xl">
                        <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-brand-300/30 bg-brand-400/10 px-4 py-2 text-sm text-brand-300">
                            <span className="h-2 w-2 rounded-full bg-emerald-400" />
                            <span>Agentic resale workflow template</span>
                        </div>
                        <h1 className="max-w-3xl text-4xl font-semibold tracking-tight text-white md:text-6xl">
                            RelistAgent turns one item description into a full resale workflow.
                        </h1>
                        <p className="mt-5 max-w-2xl text-base leading-7 text-slate-300 md:text-lg">
                            Built in Jac with graph-native orchestration, mock market research, AI pricing logic,
                            listing generation, and a publish-ready handoff for eBay sandbox once you add keys.
                        </p>
                        <div className="mt-8 grid gap-4 md:grid-cols-2">
                            <div className="rounded-2xl border border-white/8 bg-slate-950/40 p-4">
                                <p className="text-sm uppercase tracking-[0.2em] text-slate-400">Research</p>
                                <p className="mt-2 text-xl font-semibold text-white">eBay comps</p>
                                <p className="mt-2 text-sm leading-6 text-slate-400">Mock sold + active listing analysis</p>
                            </div>
                            <div className="rounded-2xl border border-white/8 bg-slate-950/40 p-4">
                                <p className="text-sm uppercase tracking-[0.2em] text-slate-400">Pricing</p>
                                <p className="mt-2 text-xl font-semibold text-white">AI strategy</p>
                                <p className="mt-2 text-sm leading-6 text-slate-400">Competitive, undercut, or premium recommendation</p>
                            </div>
                            <div className="rounded-2xl border border-white/8 bg-slate-950/40 p-4">
                                <p className="text-sm uppercase tracking-[0.2em] text-slate-400">Listing</p>
                                <p className="mt-2 text-xl font-semibold text-white">SEO copy</p>
                                <p className="mt-2 text-sm leading-6 text-slate-400">Title, description, category, and specifics</p>
                            </div>
                            <div className="rounded-2xl border border-white/8 bg-slate-950/40 p-4">
                                <p className="text-sm uppercase tracking-[0.2em] text-slate-400">Publish</p>
                                <p className="mt-2 text-xl font-semibold text-white">Sandbox-ready</p>
                                <p className="mt-2 text-sm leading-6 text-slate-400">Prepared for eBay API keys when you add them</p>
                            </div>
                        </div>
                    </div>

                    <div className="rounded-3xl border border-white/10 bg-slate-950/55 p-6 shadow-[var(--shadow-glow)] backdrop-blur-xl">
                        <div className="flex items-center justify-between gap-3">
                            <div>
                                <p className="text-sm uppercase tracking-[0.2em] text-cyan-400">Live preview</p>
                                <h2 className="mt-2 text-2xl font-semibold text-white">Run the template</h2>
                            </div>
                            <div className="rounded-full border border-amber-300/30 bg-amber-300/10 px-3 py-1 text-xs font-medium text-amber-200">
                                No keys needed
                            </div>
                        </div>

                        <div className="mt-6 space-y-4">
                            <label className="block text-sm font-medium text-slate-300">Describe your item</label>
                            <textarea
                                value={item_input}
                                onChange={lambda e: any -> None { item_input = e.target.value; }}
                                className="min-h-36 w-full rounded-2xl border border-white/10 bg-white/5 px-4 py-4 text-base text-white outline-none transition focus:border-brand-300/60 focus:bg-white/8"
                                placeholder="used Nike Dunk Low size 10, worn twice, white black colorway"
                            />
                            <button
                                onClick={submit_demo}
                                disabled={loading or not item_input.strip()}
                                className="inline-flex w-full items-center justify-center rounded-2xl bg-white px-5 py-3 text-base font-semibold text-slate-950 transition hover:bg-slate-100 disabled:cursor-not-allowed disabled:opacity-60"
                            >
                                {loading ? "Running agent..." : "Generate resale plan"}
                            </button>
                        </div>

                        <div className="mt-6 rounded-2xl border border-cyan-400/20 bg-cyan-400/8 p-4 text-sm text-cyan-100">
                            <p className="font-medium">Status</p>
                            <p className="mt-2 leading-6">{current_step}</p>
                        </div>
                    </div>
                </section>

                <section className="grid gap-6 lg:grid-cols-2 xl:grid-cols-4">
                    <div className="rounded-3xl border border-white/10 bg-white/6 p-6 backdrop-blur-xl">
                        <p className="text-sm uppercase tracking-[0.2em] text-slate-400">Market research</p>
                        <p className="mt-4 text-3xl font-semibold text-white">{result["market_research"]["num_listings_found"] or 0}</p>
                        <p className="mt-2 text-sm text-slate-400">Comparable listings found</p>
                        <p className="mt-4 text-sm text-slate-300">Avg price {format_currency(result["market_research"]["avg_price"] or 0.0)}</p>
                    </div>
                    <div className="rounded-3xl border border-white/10 bg-white/6 p-6 backdrop-blur-xl">
                        <p className="text-sm uppercase tracking-[0.2em] text-slate-400">Recommended price</p>
                        <p className="mt-4 text-3xl font-semibold text-white">{format_currency(result["pricing"]["recommended_price"] or 0.0)}</p>
                        <p className="mt-2 text-sm text-slate-400">Strategy: {result["pricing"]["strategy"] or "competitive"}</p>
                        <p className="mt-4 text-sm text-slate-300">{result["pricing"]["reasoning"] or "AI pricing rationale appears here."}</p>
                    </div>
                    <div className="rounded-3xl border border-white/10 bg-white/6 p-6 backdrop-blur-xl">
                        <p className="text-sm uppercase tracking-[0.2em] text-slate-400">Listing title</p>
                        <p className="mt-4 text-lg font-semibold text-white">{result["listing"]["title"] or "Generated SEO title"}</p>
                        <p className="mt-3 text-sm leading-6 text-slate-300">{result["listing"]["description"] or "Generated description will appear here."}</p>
                    </div>
                    <div className="rounded-3xl border border-white/10 bg-white/6 p-6 backdrop-blur-xl">
                        <p className="text-sm uppercase tracking-[0.2em] text-slate-400">Publish status</p>
                        <p className="mt-4 text-3xl font-semibold text-white">{result["published"]["status"] or "draft"}</p>
                        <p className="mt-2 text-sm text-slate-400">{result["published"]["next_step"] or "Connect eBay credentials to publish live."}</p>
                        <p className="mt-4 text-sm text-slate-300">{result["published"]["url"] or "Sandbox URL will appear here after API setup."}</p>
                    </div>
                </section>

                <section className="grid gap-6 xl:grid-cols-2">
                    <div className="rounded-3xl border border-white/10 bg-slate-950/55 p-6 backdrop-blur-xl">
                        <p className="text-sm uppercase tracking-[0.2em] text-slate-400">Autonomous pipeline</p>
                        <div className="mt-5 space-y-4">
                            <div className="flex items-start gap-4 rounded-2xl border border-white/8 bg-white/4 p-4">
                                <div className="mt-1 flex h-8 w-8 items-center justify-center rounded-full bg-brand-400/20 text-sm font-semibold text-brand-200">1</div>
                                <div>
                                    <p className="font-medium text-white">Parse item details</p>
                                    <p className="mt-1 text-sm leading-6 text-slate-400">Extract brand, model, condition, size, and category from raw text.</p>
                                </div>
                            </div>
                            <div className="flex items-start gap-4 rounded-2xl border border-white/8 bg-white/4 p-4">
                                <div className="mt-1 flex h-8 w-8 items-center justify-center rounded-full bg-brand-400/20 text-sm font-semibold text-brand-200">2</div>
                                <div>
                                    <p className="font-medium text-white">Research comps</p>
                                    <p className="mt-1 text-sm leading-6 text-slate-400">Use eBay Browse API later; template currently returns realistic mock comps.</p>
                                </div>
                            </div>
                            <div className="flex items-start gap-4 rounded-2xl border border-white/8 bg-white/4 p-4">
                                <div className="mt-1 flex h-8 w-8 items-center justify-center rounded-full bg-brand-400/20 text-sm font-semibold text-brand-200">3</div>
                                <div>
                                    <p className="font-medium text-white">Price intelligently</p>
                                    <p className="mt-1 text-sm leading-6 text-slate-400">Recommend a strategy based on market spread and item condition.</p>
                                </div>
                            </div>
                            <div className="flex items-start gap-4 rounded-2xl border border-white/8 bg-white/4 p-4">
                                <div className="mt-1 flex h-8 w-8 items-center justify-center rounded-full bg-brand-400/20 text-sm font-semibold text-brand-200">4</div>
                                <div>
                                    <p className="font-medium text-white">Generate listing</p>
                                    <p className="mt-1 text-sm leading-6 text-slate-400">Produce title, description, category, and item specifics.</p>
                                </div>
                            </div>
                            <div className="flex items-start gap-4 rounded-2xl border border-white/8 bg-white/4 p-4">
                                <div className="mt-1 flex h-8 w-8 items-center justify-center rounded-full bg-brand-400/20 text-sm font-semibold text-brand-200">5</div>
                                <div>
                                    <p className="font-medium text-white">Publish when ready</p>
                                    <p className="mt-1 text-sm leading-6 text-slate-400">Switch from draft mode to sandbox publishing once credentials are added.</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className="rounded-3xl border border-white/10 bg-white/6 p-6 backdrop-blur-xl">
                        <div className="flex flex-wrap items-center justify-between gap-3">
                            <div>
                                <p className="text-sm uppercase tracking-[0.2em] text-slate-400">Sample output</p>
                                <h3 className="mt-2 text-2xl font-semibold text-white">What the agent returns</h3>
                            </div>
                            <div className="rounded-full border border-emerald-400/20 bg-emerald-400/10 px-3 py-1 text-xs font-medium text-emerald-200">
                                Mock backend active
                            </div>
                        </div>

                        <div className="mt-6 grid gap-4 md:grid-cols-2">
                            <div className="rounded-2xl bg-slate-950/45 p-4">
                                <p className="text-sm text-slate-400">Item</p>
                                <p className="mt-2 text-white">{result["item"]["description"] or item_input}</p>
                                <p className="mt-3 text-sm text-slate-300">Brand: {result["item"]["brand"] or "Nike"}</p>
                                <p className="text-sm text-slate-300">Condition: {result["item"]["condition"] or "Used"}</p>
                            </div>
                            <div className="rounded-2xl bg-slate-950/45 p-4">
                                <p className="text-sm text-slate-400">Price range</p>
                                <p className="mt-2 text-white">{format_currency(result["market_research"]["price_range"][0] or 0.0)} - {format_currency(result["market_research"]["price_range"][1] or 0.0)}</p>
                                <p className="mt-3 text-sm text-slate-300">Category: {result["listing"]["category_id"] or "11450"}</p>
                                <p className="text-sm text-slate-300">Condition ID: {result["listing"]["condition_id"] or "3000"}</p>
                            </div>
                        </div>
                    </div>
                </section>
            </div>
        </main>
    );
}
