<template>
  <button @click="throwError">TEST ERROR</button>
</template>

<script>
export default {
  name: 'ErrorButton',
  methods: {
    throwError() {
      throw new Error('Vue 3 TEST ERROR')
    }
  }
}
</script>
