## 📝 Summary

- Set Vite's `base` to the repo subpath in `vite.config.ts` so the project-page build resolves every asset under `https://<owner>.github.io/<repo>/`.
- Make the create-vite demo's `icons.svg` sprite references base-aware through `import.meta.env.BASE_URL`, so the `<use href>` icons resolve under the subpath instead of 404ing at the domain root.

　

## 🎯 Scope

- Vite config and the scaffold's demo asset references only — no deploy workflow, no application logic.

　

## ✅ Test plan

- [x] `vite.config.ts` sets `base` to `/<repo>/`
- [x] `npm run build` produces `dist/` with subpath-prefixed asset paths
- [x] Every `<use href>` to the icons sprite resolves through `import.meta.env.BASE_URL`
- [x] After deploy, the favicon and the demo sprite icons render at the live URL

🤖 Generated with [Claude Code](https://claude.com/claude-code)
