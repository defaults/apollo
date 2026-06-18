document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.code-copy-button').forEach(function (button) {
        button.addEventListener('click', async function () {
            const block = button.closest('.code-block');
            const code = block ? block.querySelector('pre code') : null;
            if (!code) return;

            const text = code.innerText.replace(/\n$/, '');
            const originalLabel = button.textContent;

            try {
                if (navigator.clipboard && window.isSecureContext) {
                    await navigator.clipboard.writeText(text);
                } else {
                    const textarea = document.createElement('textarea');
                    textarea.value = text;
                    textarea.setAttribute('readonly', '');
                    textarea.style.position = 'fixed';
                    textarea.style.left = '-9999px';
                    document.body.appendChild(textarea);
                    textarea.select();
                    document.execCommand('copy');
                    document.body.removeChild(textarea);
                }

                button.textContent = 'Copied';
                button.classList.add('copied');
                window.setTimeout(function () {
                    button.textContent = originalLabel;
                    button.classList.remove('copied');
                }, 1600);
            } catch (_error) {
                button.textContent = 'Failed';
                window.setTimeout(function () {
                    button.textContent = originalLabel;
                }, 1600);
            }
        });
    });
});
