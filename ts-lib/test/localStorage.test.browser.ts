import { describe, expect, test } from "vitest";

import { BrowserTestData } from "./browserCommon.js";

import { compress, decompress } from "../dist/smol-string.js";

describe("compress and decompress via localStorage", async () => {
	for (const { name, input } of BrowserTestData) {
		test(name, async () => {
			const compressed = await compress(input);

			localStorage.setItem("compressed", compressed);
			const restored = localStorage.getItem("compressed")!;

			const decompressed = await decompress(restored);

			expect(decompressed).toBe(input);
		});
	}
});
