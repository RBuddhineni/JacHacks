cl import ".styles.global.css";
cl import from .components.openAEyeApp { OpenAEyeApp }

cl {
    def:pub app() -> JsxElement {
        return <OpenAEyeApp />;
    }
}
