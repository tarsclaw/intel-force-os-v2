import { defineConfig } from "tsup";

export default defineConfig({
  entry: {
    index: "src/index.ts",
    // CLI entrypoints consumed by Concierge cycle.sh Step 11 +
    // Cash Conductor cycle.sh Step 10 (node dist/bin/<name>.js).
    "bin/propose": "bin/propose.ts",
    "bin/await": "bin/await.ts",
    "bin/record-decision": "bin/record-decision.ts",
  },
  format: ["esm"],
  target: "node20",
  platform: "node",
  outDir: "dist",
  splitting: false,
  sourcemap: true,
  clean: true,
  dts: { entry: { index: "src/index.ts" } },
});
