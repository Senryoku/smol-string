/// <reference types="vitest" />
import { defineConfig } from "vite";
import dts from "vite-plugin-dts";
import pkg from "./package.json" assert { type: "json" };

import topLevelAwait from "vite-plugin-top-level-await";

import { exec } from "child_process";

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
				{
					name: "optimize-wasm",
					async buildStart(options) {
						exec(
							"npx wasm-opt -O3 ../zig-out/lib/smol-string.wasm -o ./src/module.wasm"
						);
					},
				},
			];
		},
	},
	plugins: [
		dts(), // emit TS declaration files
	],
	test: {},
});
