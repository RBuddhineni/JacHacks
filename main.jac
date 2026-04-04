cl import from .components.pivotScreen { PivotScreen }
cl import ".styles.global.css";

cl {
    def:pub app() -> JsxElement {
        return <PivotScreen />;
    }
}
