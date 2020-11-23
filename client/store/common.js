export const state = () => ({
  canonicalForm: '',
  uniqueWords: [],
})

export const mutations = {
  mutSetCanonicalForm(state, data) {
    state.canonicalForm = data
  },
  mutSetUniqueWords(state, data) {
    state.uniqueWords = data
  },
}

export const actions = {
  fetchResult({ commit }, data) {
    return this.$axios.$get(`/result?string=${data}`).then((res) => {
      commit('mutSetCanonicalForm', res.canonical_form)
      commit('mutSetUniqueWords', res.unique_words)
    })
  },
}

export const getters = {
  getCanonicalForm(state) {
    return state.canonicalForm
  },
  getUniqueWords(state) {
    return state.uniqueWords
  },
}
