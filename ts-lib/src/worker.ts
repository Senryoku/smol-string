export type Message = {
	command: string;
	id: number;
	data: string;
};

self.onmessage = function (e: { data: Message }) {
	const { command, id, data } = e.data;
	switch (command) {
		case "decompress": {
			self.postMessage({ id, data: data });
			break;
		}
		case "compress": {
			self.postMessage({ id, data: data });
			break;
		}
	}
};
