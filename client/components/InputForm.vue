<template>
  <div class="col-content">
    <div>
      <b-form-input @input="handleInput($event)" />
      <p class="mt-2">
        <strong>Különböző szavak számának kanonikus alakja:</strong> <br />{{
          canonicalForm
        }}
      </p>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
const _ = require('lodash')

export default {
  computed: {
    ...mapGetters({
      canonicalForm: 'common/getCanonicalForm',
    }),
  },
  methods: {
    ...mapActions({
      fetchResult: 'common/fetchResult',
    }),
    handleInput: _.throttle(
      function (event) {
        this.fetchResult(event)
      },
      1000,
      { leading: false }
    ),
  },
}
</script>

<style lang="scss" scoped>
.col-content {
  display: flex;
  align-items: center;

  & > div {
    width: 100%;
  }
}
</style>
