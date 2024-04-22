import { TestData } from "./common";

export function randomStr(len: number) {
	var arr = new Uint8Array(len);
	window.crypto.getRandomValues(arr);
	return new TextDecoder().decode(arr);
}

export const BrowserTestData = structuredClone(TestData);

for (let i = 0; i < 10; ++i) {
	BrowserTestData.push({
		name: `Random string #${i}`,
		input: randomStr(65536),
	});
}
