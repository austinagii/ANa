<style>
    #gibber-generate-form {
        display: flex;
        align-items: center;
        justify-content: center;
        height: 100vh;
    }

    #gibber-generate-form input[type="text"] {
        margin-right: 10px;
    }
</style>

<script>
    function handleSubmit() {
        console.log('submitted');    
    }
</script>

<div>
    <form on:submit|preventDefault={handleSubmit} id='gibber-generate-form'>
        <input type="text"/>
        <button type="submit">Submit</button>
    </form>
</div>