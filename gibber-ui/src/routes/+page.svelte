<style>
    #gibber-content-area {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        height: 100vh;
    }

    #gibber-generate-form input[type="text"] {
        margin-right: 10px;
    }
</style>

<script lang="ts">
    const api_url: string = 'http://api.gibber.kadeemaustin.ai:8000';
    let gibber = "";
    
    async function fetch_text() {
        let responseJson = await fetch(api_url).then(response => response.json());
        gibber = responseJson['text'];
    }
</script>

<div id='gibber-content-area'>
    <p>{gibber}</p>
    <form on:submit|preventDefault={fetch_text}>
        <button type="submit">Generate New Gibber</button>
    </form>
</div>