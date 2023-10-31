import { describe, expect, test } from "vitest";

import { TestData } from "./common.js";

import { compress, decompress } from "../dist/smol-string.js";
import {
	compressPacked,
	decompressPacked,
} from "../dist/smol-string-packed.js";

describe("compress and decompress via sessionStorage", () => {
	for (const { name, input } of TestData) {
		test(name, async () => {
			const compressed = compress(input);

			sessionStorage.setItem("compressed", compressed);
			const restored = sessionStorage.getItem("compressed")!;

			const decompressed = decompress(restored);

			expect(decompressed).toBe(input);
		});
	}
});

describe("compressPacked and decompressPacked via sessionStorage", () => {
	for (const { name, input } of TestData) {
		test(name, async () => {
			const compressed = compressPacked(input);

			sessionStorage.setItem("compressed", compressed);
			const restored = sessionStorage.getItem("compressed")!;

			const decompressed = decompressPacked(restored);

			expect(decompressed).toBe(input);
		});
	}
});
