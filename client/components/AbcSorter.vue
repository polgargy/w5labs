<template>
  <div class="col-content">
    <p><strong>Különböző szavak abc sorrendben:</strong></p>
    <ul class="list-unstyled">
      <li v-for="(word, index) in uniqueWords" :key="index">{{ word }}</li>
    </ul>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
export default {
  computed: {
    ...mapGetters({
      uniqueWords: 'common/getUniqueWords',
    }),
  },
}
</script>

<style lang="scss" scoped>
.col-content {
  overflow-y: auto;
}
</style>
