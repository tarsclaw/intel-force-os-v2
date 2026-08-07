import { defineConfig } from "tsup";

export default defineConfig({
  entry: {
    index: "src/index.ts",
    // CLI entrypoints shelled from agent cycle.sh layers (W3 integration):
    //   node dist/bin/resolve-approver.js --tenant ... --action-type ...
    //   node dist/bin/seed-identity-map.js --tenant ... --csv ...
    "bin/resolve-approver": "bin/resolve-approver.ts",
    "bin/seed-identity-map": "bin/seed-identity-map.ts",
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
