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
-- ATENCAO 2: as chaves terminal_* (usadas nos slots de sintaxe) só existem em
-- esquemas PREDEFINIDOS. Se você ligar "use wallpaper colors", elas desaparecem,
-- o render falha e o arquivo gerado para de ser atualizado (o Neovim continua
-- funcionando com o último tema gerado). Nesse caso troque para os tokens Material:
-- error / tertiary / secondary / primary / tertiary_fixed_dim / primary_fixed_dim /
-- secondary_fixed_dim / error_container.
-- Referência: https://docs.noctalia.dev/v4/theming/user-templates/

local M = {}

function M.setup()
	require("base16-colorscheme").setup({
		-- Estrutura da UI: tokens Material (dão mais profundidade que as 16 ANSI).
		base00 = "{{colors.terminal_background.default.hex}}", -- background (== surface)
		base01 = "{{colors.surface_container.default.hex}}", -- background alternativo, CursorLine
		base02 = "{{colors.terminal_selection_bg.default.hex}}", -- seleção (igual à do foot)
		base03 = "{{colors.outline.default.hex}}", -- comentários, texto apagado
		base04 = "{{colors.on_surface_variant.default.hex}}", -- foreground escuro
		base05 = "{{colors.terminal_foreground.default.hex}}", -- foreground padrão (== on_surface)
		base06 = "{{colors.on_surface.default.hex}}", -- foreground claro
		base07 = "{{colors.on_background.default.hex}}", -- foreground mais claro
		-- Sintaxe: paleta ANSI literal do esquema, a MESMA que o foot recebe.
		-- Derivar do Material aqui erra feio quando primary não é azul (ex.: Everforest,
		-- em que o slot "azul" saía esverdeado).
		base08 = "{{colors.terminal_normal_red.default.hex}}", -- vermelho
		base09 = "{{colors.terminal_bright_red.default.hex}}", -- laranja
		base0A = "{{colors.terminal_normal_yellow.default.hex}}", -- amarelo
		base0B = "{{colors.terminal_normal_green.default.hex}}", -- verde
		base0C = "{{colors.terminal_normal_cyan.default.hex}}", -- ciano
		base0D = "{{colors.terminal_normal_blue.default.hex}}", -- azul
		base0E = "{{colors.terminal_normal_magenta.default.hex}}", -- magenta
		base0F = "{{colors.terminal_bright_magenta.default.hex}}", -- marrom/extra
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
