import { describe, expect, test } from "vitest";

import { BrowserTestData } from "./browserCommon.js";

import { compress, decompress } from "../dist/smol-string-worker.js";

describe("compress and decompress", () => {
	for (const { name, input } of BrowserTestData) {
		test(name, async () => {
			const compressed = await compress(input);
			const decompressed = await decompress(compressed);
			expect(decompressed).toBe(input);
		});
	}
});
