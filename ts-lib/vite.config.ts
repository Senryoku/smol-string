/// <reference types="vitest" />
import { defineConfig } from "vite";
import dts from "vite-plugin-dts";
import pkg from "./package.json" assert { type: "json" };

import topLevelAwait from "vite-plugin-top-level-await";

export default defineConfig({
	build: {
		lib: {
			entry: {
				"smol-string": "./src/smol-string.ts",
				"smol-string-worker": "./src/smol-string-worker.ts",
			},
			formats: ["es"],
		},
		rollupOptions: {
			external: [
				...Object.keys(pkg["dependencies"] ?? {}), // don't bundle dependencies
				/^node:.*/, // don't bundle built-in Node.js modules (use protocol imports!)
			],
		},
		target: "esnext",
	},
	worker: {
		format: "es",
		plugins() {
			return [
				topLevelAwait({
					// The export name of top-level await promise for each chunk module
					promiseExportName: "__tla",
					// The function to generate import names of top-level await promise in each chunk module
					promiseImportName: (i) => `__tla_${i}`,
				}),
			];
		},
	},
	plugins: [
		dts(), // emit TS declaration files
	],
	test: {},
});
