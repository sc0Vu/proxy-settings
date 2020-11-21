<template>
  <div id="app">
    <Header />
    <WhatIsProxy />
    <router-view/>
    <Footer />
  </div>
</template>

<script>
import Footer from '@/components/Footer'
import Header from '@/components/Header'
import WhatIsProxy from '@/components/WhatIsProxy'

export default {
  name: 'App',
  components: {
    Header,
    WhatIsProxy,
    Footer
  }
}
</script>
