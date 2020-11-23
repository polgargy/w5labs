<template>
  <b-container>
    <b-row align-v="center">
      <b-col cols="12" md="6">
        <InputForm />
      </b-col>
      <b-col cols="12" md="6">
        <AbcSorter />
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import InputForm from '~/components/InputForm.vue'
import AbcSorter from '~/components/AbcSorter.vue'

export default {
  components: {
    InputForm,
    AbcSorter,
  },
}
</script>

<style lang="scss" scoped>
.container {
  height: 100vh;

  .row {
    height: 100%;
  }
}

.col-content {
  background: #fff;
  border-radius: 0.5rem;
  height: 40vh;
  padding: 1rem;
}
</style>
