<template>
  <div class="about">
    <h1>This is an about page</h1>
    <button @click="throwError">TEST ERROR</button>
  </div>
</template>

<style>
@media (min-width: 1024px) {
  .about {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>

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
