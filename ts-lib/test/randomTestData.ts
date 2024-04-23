let getRandomBytes = (
	typeof self !== "undefined" && self.crypto
		? // Browsers
		  () => {
				const maxBytes = 65536;
				return function (len: number) {
					const a = new Uint8Array(len);
					for (let i = 0; i < len; i += maxBytes) {
						self.crypto.getRandomValues(
							a.subarray(i, i + Math.min(len - i, maxBytes))
						);
					}
					return a;
				};
		  }
		: // Node
		  () => require("crypto").randomBytes
)();

export function randomStr(len: number) {
	const arr = getRandomBytes(len);
	return new TextDecoder().decode(arr);
}

export const RandomTestData: { name: string; input: string }[] = [];

for (let i = 0; i < 10; ++i) {
	RandomTestData.push({
		name: `Random string #${i}`,
		input: randomStr(65536),
	});
}
