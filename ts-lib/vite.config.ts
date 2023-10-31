/// <reference types="vitest" />
import { defineConfig } from "vite";
import dts from "vite-plugin-dts";
import pkg from "./package.json" assert { type: "json" };

export default defineConfig({
	build: {
		lib: {
			entry: {
				"smol-string": "./src/smol-string.ts",
				"smol-string-packed": "./src/smol-string-packed.ts",
				"smol-string-worker": "./src/smol-string-worker.ts",
				"smol-string-worker-packed":
					"./src/smol-string-worker-packed.ts",
			},
			formats: ["es"],
		},
		rollupOptions: {
			external: [
				...Object.keys(pkg.dependencies), // don't bundle dependencies
				/^node:.*/, // don't bundle built-in Node.js modules (use protocol imports!)
			],
		},
		target: "esnext", // transpile as little as possible
	},
	worker: {
		format: "es",
	},
	plugins: [
		dts(), // emit TS declaration files
	],
	test: {},
});
