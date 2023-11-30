function StartLlama()
    !systemctl --user start llama
endfunction

nnoremap <A-a> :execute StartLlama() \| NeoAI <CR>
vnoremap <A-a> :NeoAIContext<CR>
vnoremap <A-i> :execute StartLlama() \| NeoAIInjectContext<Space>
nnoremap <A-i> :execute StartLlama() \| NeoAIInject<Space>
inoremap <A-a> <Esc>:execute StartLlama() \| NeoAIInject<Space>
