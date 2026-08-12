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
		base00 = "#1c1917", -- background
		base01 = "#403833", -- background alternativo, CursorLine
		base02 = "#4b423c", -- seleção
		base03 = "#888f94", -- comentários, texto apagado
		base04 = "#888f94", -- foreground escuro
		base05 = "#b4bdc3", -- foreground padrão
		base06 = "#b4bdc3", -- foreground claro
		base07 = "#b4bdc3", -- foreground mais claro
		-- Sintaxe: derivada dos acentos Material. Isso é robusto a qualquer esquema/modo,
		-- mas cuidado: o "slot azul" (base0D) vem de primary_fixed_dim e nem sempre é azul
		-- de fato (em esquemas cujo primary é verde/roxo, o hue pode escorregar). Se algum
		-- esquema específico ficar estranho, reatribua o slot problemático à mão (ex.:
		-- base0D = secondary, base0C = tertiary...).
		base08 = "#de6e7c", -- vermelho: variáveis, erros
		base09 = "#9f948f", -- laranja: inteiros, constantes
		base0A = "#888f94", -- amarelo: classes, fundo de busca
		base0B = "#b4bdc3", -- verde: strings, diff add
		base0C = "#e9b096", -- ciano: regex, escapes
		base0D = "#96c8e9", -- azul: funções, métodos
		base0E = "#96c6e9", -- magenta: keywords, storage
		base0F = "#891120", -- marrom/extra: deprecated
	})

	-- O base16 deixa o Telescope bem cru; estes overrides usam os tokens Material
	-- que não têm equivalente nos 16 slots (containers, outline).
	local hi = function(group, opts)
		vim.api.nvim_set_hl(0, group, opts)
	end

	hi("TelescopeNormal", { fg = "#b4bdc3", bg = "#1c1917" })
	hi("TelescopeBorder", { fg = "#888f94", bg = "#1c1917" })
	hi("TelescopePromptNormal", { fg = "#b4bdc3", bg = "#1c1917" })
	hi("TelescopePromptBorder", { fg = "#888f94", bg = "#1c1917" })
	hi("TelescopePromptPrefix", { fg = "#b4bdc3", bg = "#1c1917" })
	hi(
		"TelescopePromptCounter",
		{ fg = "#888f94", bg = "#1c1917" }
	)
	hi("TelescopePromptTitle", { fg = "#1c1917", bg = "#b4bdc3" })
	hi("TelescopePreviewTitle", { fg = "#1c1917", bg = "#888f94" })
	hi("TelescopeResultsTitle", { fg = "#1c1917", bg = "#9f948f" })
	hi(
		"TelescopeSelection",
		{ fg = "#b4bdc3", bg = "#4b423c" }
	)
	hi(
		"TelescopeSelectionCaret",
		{ fg = "#b4bdc3", bg = "#4b423c" }
	)
	hi("TelescopeMatching", { fg = "#b4bdc3", bold = true })

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
