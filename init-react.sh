#!/bin/bash

git init
npm init -y
npm i express

npm i -D react react-dom && \
npm i -D webpack webpack-cli && \ 
npm i -D typescript ts-loader && \
npm i -D ts-node-dev && \
npm i -D eslint @typescript-eslint/parser eslint-plugin-react eslint-plugin-react-hooks && \
npm i -D jest ts-jest  # playwrite.js https://playwright.dev

mkdir -p dist
mkdir -p src/components
mkdir -p src/server

touch ./dist/.gitkeep
touch ./src/index.tsx
touch ./src/components/app.tsx
touch ./src/server/server.tsx

cat << \EOT >> .eslintrc.js
module.exports = {
    parser: "@typescript-eslint/parser",
    parserOptions: {
      project: "tsconfig.json",
      sourceType: "module",
    },
    env: {
      browser: true,
      es6: true,
      jest: true,
      node: true,
    },
    plugins: [
      "eslint-plugin-react",
      "eslint-plugin-react-hooks",
    ],
    extends: [
      "eslint:recommended",
      "plugin:react/recommended",
      "plugin:react-hooks/recommended",
    ],
    settings: {
      "react": {
        version: "detect",
      },
    },
    rules: {
      "react/prop-types": "off",
      "react/react-in-jsx-scope": "off",
  
      // You can do more rule customizations here...
    },
  };
  
EOT


cat << \EOS > tsconfig.json
{
  "compilerOptions": {
    "target": "es5",
    "module": "commonjs",
    "downlevelIteration": true,
    "lib": ["dom", "es2021", "scripthost"],
    "jsx": "react-jsx",
    "allowJs": false,
    "sourceMap": true,
    "skipLibCheck": true,
    "moduleResolution": "node",
    "esModuleInterop": true,
    "preserveSymlinks": true,
    "resolveJsonModule": true
  },
  "include": ["src"]
}

EOS


cat <<\EOW > webpack.config.js
module.exports = {
  entry: "./src/index.tsx",
  resolve: {
    extensions: [".ts", ".tsx", ".js", ".json"],
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        exclude: /node_modules/,
        use: {
          loader: "ts-loader",
        },
      },
    ],
  },
};
EOW

cat <<\EOX > npm-scripts.json
scripts: {
  "test": "jest",
  "dev:server": "tsnd --files --respawn src/server/server.tsx --ignore-watch node_modules,dist",
  "dev:bundler": "webpack -w --mode=development"
}
EOX

cat <<\EOS > ./src/components/app.tsx
import { useState } from "react";

export default function App() {
  const [count, setCount] = useState(0);
  return (
    <div>
      This is a sample stateful and server-side
      rendered React application.
      <br />
      <br />
      Here is a button that will track
      how many times you click it:
      <br />
      <br />
      <button onClick={() => setCount(count + 1)}>{count}</button>
    </div>
  );
}
EOS

cat <<\EOS > ./src/index.tsx
import ReactDOM from "react-dom";

import App from "./components/app";

const container = document.getElementById("app");
ReactDOM.hydrateRoot(container, <App />);
EOS

cat <<\EOS > ./src/server/server.tsx
import express from "express";
import ReactDOMServer from "react-dom/server";

import App from "../components/app";

const server = express();
server.use(express.static("dist"));

server.get("/", (req, res) => {
  const initialMarkup = ReactDOMServer.renderToString(<App />);

  res.send(`
    <html>
      <head>
        <title>Sample React App</title>
      </head>
      <body>
        <div id="app">${initialMarkup}</div>
        <script src="/main.js"></script>
      </body>
    </html>
  `)
});

server.listen(4242, () => console.log("Server is running port 4242..."));
EOS

cat << \EOG > .gitignore
# binaries
bin/
dist/
lib/

# editors
*.swp
.idea/
.vs/
.vscode/
.DS_Store
EOG


npm i -D npe
node_modules/.bin/npe scripts.test "jest"
node_modules/.bin/npe scripts.dev:server "tsnd --files --respawn src/server/server.tsx --ignore-watch node_modules,dist"
node_modules/.bin/npe scripts.dev:bundler "webpack -w --mode=development"

#echo to remote:
# echo "rm -rf dist node_modules/ src .eslintrc.js npm-scripts.json package* tsconfig.json webpack.config.js .gitignore"