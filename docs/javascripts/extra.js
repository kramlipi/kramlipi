/* Optional: announce bar dismiss persistence */
document$.subscribe(function () {
  if (typeof mermaid !== "undefined") {
    mermaid.initialize({ startOnLoad: true, theme: "neutral" });
  }
});
