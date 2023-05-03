<style>
    #prompt-completion {
        padding: 3em;
    }
    #chat-area {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        height: 100vh;
    }
</style>

<script lang="ts">
    let prompt: string = "";
    let promptCompletion: string = "";
    
    async function completePrompt() {
        let requestJson = { 'prompt': prompt };
        let responseJson = await fetch('http://localhost:8000/prompt-completion', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(requestJson)
        }).then(response => response.json());
        promptCompletion = responseJson['completion'];
    }
</script>

<div id='chat-area'>
    <p id="prompt-completion">{promptCompletion}</p>
    <form on:submit|preventDefault={completePrompt}>
        <label for="prompt">Prompt:</label>
        <input id="prompt-input" type="text" name="prompt" bind:value={prompt}>
        <button type="submit">Go</button>
    </form>
</div>