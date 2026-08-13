-- Template do Noctalia para o Neovim (base16-nvim).
--
-- ESTE é o arquivo que você edita. Ele contém placeholders de cor e por isso
-- NÃO é Lua válido — mantenha-o fora de ~/.config/nvim/.
--
-- O Noctalia renderiza este template para ~/.config/nvim/lua/noctalia.lua a cada
-- troca de esquema de cores, e depois manda SIGUSR1 para os nvim abertos.
-- Registro em: ~/.config/noctalia/user-templates.toml
--
-- Sintaxe dos placeholders (duas chaves): colors . nome . modo . formato
--   modo:     default (segue dark/light atual) | dark | light
--   formato:  hex | hex_stripped | rgb | rgba | hsl | ...
-- ATENCAO 1: nao escreva placeholders de exemplo nos comentarios — o renderizador
-- valida TODO o arquivo e aborta se encontrar um nome de cor inexistente.
--
-- ATENCAO 2: este template usa SOMENTE tokens Material (surface, on_surface,
-- primary, error, *_fixed_dim, *_container...). Eles existem em qualquer fonte de
-- esquema (predefinido, wallpaper ou custom) e em ambos os modos dark/light.
-- NÃO volte a usar as chaves terminal_* (terminal_background, terminal_normal_red,
-- etc.): elas só existem em esquemas PREDEFINIDOS com bloco de terminal. Ao alternar
-- para "use wallpaper colors" ou para um esquema/modo sem terminais, elas somem, o
-- render falha e o arquivo gerado para de ser atualizado (o Neovim segue no último
-- tema gerado). Foi exatamente esse o bug ao testar outros esquemas + dark/light.
-- Referência: https://docs.noctalia.dev/v5/theming/palette/

local M = {}

function M.setup()
	require("base16-colorscheme").setup({
		-- Estrutura da UI: tokens Material (dão mais profundidade que as 16 ANSI).
		base00 = "{{colors.surface.default.hex}}", -- background
		base01 = "{{colors.surface_container.default.hex}}", -- background alternativo, CursorLine
		base02 = "{{colors.surface_container_high.default.hex}}", -- seleção
		base03 = "{{colors.outline.default.hex}}", -- comentários, texto apagado
		base04 = "{{colors.on_surface_variant.default.hex}}", -- foreground escuro
		base05 = "{{colors.on_surface.default.hex}}", -- foreground padrão
		base06 = "{{colors.on_surface.default.hex}}", -- foreground claro
		base07 = "{{colors.on_background.default.hex}}", -- foreground mais claro
		-- Sintaxe: derivada dos acentos Material. Isso é robusto a qualquer esquema/modo,
		-- mas cuidado: o "slot azul" (base0D) vem de primary_fixed_dim e nem sempre é azul
		-- de fato (em esquemas cujo primary é verde/roxo, o hue pode escorregar). Se algum
		-- esquema específico ficar estranho, reatribua o slot problemático à mão (ex.:
		-- base0D = secondary, base0C = tertiary...).
		base08 = "{{colors.error.default.hex}}", -- vermelho: variáveis, erros
		base09 = "{{colors.tertiary.default.hex}}", -- laranja: inteiros, constantes
		base0A = "{{colors.secondary.default.hex}}", -- amarelo: classes, fundo de busca
		base0B = "{{colors.primary.default.hex}}", -- verde: strings, diff add
		base0C = "{{colors.tertiary_fixed_dim.default.hex}}", -- ciano: regex, escapes
		base0D = "{{colors.primary_fixed_dim.default.hex}}", -- azul: funções, métodos
		base0E = "{{colors.secondary_fixed_dim.default.hex}}", -- magenta: keywords, storage
		base0F = "{{colors.error_container.default.hex}}", -- marrom/extra: deprecated
	})

	-- O base16 deixa o Telescope bem cru; estes overrides usam os tokens Material
	-- que não têm equivalente nos 16 slots (containers, outline).
	local hi = function(group, opts)
		vim.api.nvim_set_hl(0, group, opts)
	end

	hi("TelescopeNormal", { fg = "{{colors.on_surface.default.hex}}", bg = "{{colors.surface.default.hex}}" })
	hi("TelescopeBorder", { fg = "{{colors.outline.default.hex}}", bg = "{{colors.surface.default.hex}}" })
	hi("TelescopePromptNormal", { fg = "{{colors.on_surface.default.hex}}", bg = "{{colors.surface.default.hex}}" })
	hi("TelescopePromptBorder", { fg = "{{colors.outline.default.hex}}", bg = "{{colors.surface.default.hex}}" })
	hi("TelescopePromptPrefix", { fg = "{{colors.primary.default.hex}}", bg = "{{colors.surface.default.hex}}" })
	hi(
		"TelescopePromptCounter",
		{ fg = "{{colors.on_surface_variant.default.hex}}", bg = "{{colors.surface.default.hex}}" }
	)
	hi("TelescopePromptTitle", { fg = "{{colors.surface.default.hex}}", bg = "{{colors.primary.default.hex}}" })
	hi("TelescopePreviewTitle", { fg = "{{colors.surface.default.hex}}", bg = "{{colors.secondary.default.hex}}" })
	hi("TelescopeResultsTitle", { fg = "{{colors.surface.default.hex}}", bg = "{{colors.tertiary.default.hex}}" })
	hi(
		"TelescopeSelection",
		{ fg = "{{colors.on_surface.default.hex}}", bg = "{{colors.surface_container_high.default.hex}}" }
	)
	hi(
		"TelescopeSelectionCaret",
		{ fg = "{{colors.primary.default.hex}}", bg = "{{colors.surface_container_high.default.hex}}" }
	)
	hi("TelescopeMatching", { fg = "{{colors.primary.default.hex}}", bold = true })

	-- Adicione outros grupos aqui se quiser (which-key, mini.indentscope, markview...).

	-- O base16-nvim não define colors_name quando chamado via setup(); sem isso
	-- plugins que checam o tema atual (e o :Telescope colorscheme) não o reconhecem.
	vim.g.colors_name = "noctalia"
end

-- Hot reload: o post_hook manda SIGUSR1 para os nvim abertos; recarregamos o módulo
-- e reaplicamos. O handle vive em um global por dois motivos: (1) como local ele não
-- é referenciado pelo callback e pode ser coletado pelo GC, derrubando o reload em
-- silêncio; (2) este arquivo é re-executado a cada reload, e a guarda evita empilhar
-- um handler novo a cada troca de tema.
if not _G.__noctalia_sigusr1 then
	local signal = vim.uv.new_signal()
	_G.__noctalia_sigusr1 = signal
	signal:start(
		"sigusr1",
		vim.schedule_wrap(function()
			package.loaded["noctalia"] = nil
			local ok, mod = pcall(require, "noctalia")
			if ok then
				mod.setup()
			end
		end)
	)
end

return M
