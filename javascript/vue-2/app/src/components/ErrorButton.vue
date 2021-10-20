<template>
  <button v-on:click="throwError()">ERROR BUTTON</button>
</template>

<script>
export default {
  name: 'ErrorButton',
  methods: {
    throwError: function() {
      throw new Error("Vue2 Error Test")
    }
  }
}
</script>
