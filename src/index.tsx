import * as ReactDOMClient from "react-dom/client"

import App from "./components/app";

const container = document.getElementById("app")!;
ReactDOMClient.hydrateRoot(container, <App />)
