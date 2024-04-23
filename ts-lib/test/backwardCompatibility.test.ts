import { randomBytes } from "crypto";

import { describe, expect, test } from "vitest";

import { TestData } from "./common.js";

import { compress, decompress } from "../dist/smol-string.js";

import {
	compress as npmCompress,
	decompress as npmDecompress,
} from "smol-string";

export function randomStr(len: number) {
	var arr = randomBytes(len);
	return new TextDecoder().decode(arr);
}

describe("compress using previous version and decompress using latest version", () => {
	for (const { name, input } of TestData) {
		test(name, async () => {
			const compressed = npmCompress(input);
			const decompressed = decompress(compressed);
			expect(decompressed).toBe(input);
		});
	}

	for (let i = 0; i < 10; ++i) {
		test(`Random #${i}`, async () => {
			const input = randomStr(65536);
			const compressed = npmCompress(input);
			const decompressed = decompress(compressed);
			expect(decompressed).toBe(input);
		});
	}
});

describe("compress using latest version and decompress using previous version", () => {
	for (const { name, input } of TestData) {
		test(name, async () => {
			const compressed = compress(input);
			const decompressed = npmDecompress(compressed);
			expect(decompressed).toBe(input);
		});

		for (let i = 0; i < 10; ++i) {
			test(`Random #${i}`, async () => {
				const input = randomStr(65536);
				const compressed = compress(input);
				const decompressed = npmDecompress(compressed);
				expect(decompressed).toBe(input);
			});
		}
	}
});
