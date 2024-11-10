import { defineConfig, mergeConfig } from "vitest/config";
import viteConfig from "./vite.config";

// Config for tests ran only in browsers.
// Currently use to tests that interacts with localStorage.

export default mergeConfig(
	viteConfig,
	defineConfig({
		test: {
			browser: {
				enabled: true,
				provider: "webdriverio",
				name: "chrome",
			},
			include: ["test/*.test.ts", "test/*.test.browser.ts"],
		},
	})
);
