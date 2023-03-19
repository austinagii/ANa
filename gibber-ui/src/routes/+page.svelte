<style>
    #gibber-content-area {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        height: 100vh;
    }
</style>

<script lang="ts">
    const api_url: string = 'http://localhost:8000';
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