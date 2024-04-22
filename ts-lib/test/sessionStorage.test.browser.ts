import { describe, expect, test } from "vitest";

import { BrowserTestData } from "./browserCommon.js";

import { compress, decompress } from "../dist/smol-string.js";

describe("compress and decompress via sessionStorage", () => {
	for (const { name, input } of BrowserTestData) {
		test(name, async () => {
			const compressed = compress(input);

			sessionStorage.setItem("compressed", compressed);
			const restored = sessionStorage.getItem("compressed")!;

			const decompressed = decompress(restored);

			expect(decompressed).toBe(input);
		});
	}
});
