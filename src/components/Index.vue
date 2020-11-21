<template>
  <section class="index">
    <div class="container">
      <div class="field">
        <label class="label">Proxy</label>
        <div class="control">
          <div class="select">
            <select v-model="proxyType">
              <option value="0">Select dropdown</option>
              <option :value="i" :key="i" v-for="(v, i) in proxyTypes">{{ v.text }}</option>
            </select>
          </div>
        </div>
      </div>

      <template v-if="isSocks5">
        <div class="field">
          <label class="label">Proxy hostname</label>
          <div class="control">
            <input class="input" type="text" v-model="proxyHostname" placeholder="proxy hostname, eg localhost:1080">
          </div>
        </div>

        <div class="field">
          <label class="label">Request URL</label>
          <div class="control">
            <input class="input" type="text" v-model="requestURL" placeholder="request URL">
          </div>
        </div>

        <div class="field">
          <label class="checkbox">
            <input type="checkbox" v-model="verbose">
            Verbose
          </label>
        </div>
      </template>

      <template v-if="isHTTP">
        <div class="field">
          <label class="label">Proxy hostname</label>
          <div class="control">
            <input class="input" type="text" v-model="proxyHostname" placeholder="proxy hostname, eg localhost:1080">
          </div>
        </div>

        <div class="field">
          <label class="label">Request URL</label>
          <div class="control">
            <input class="input" type="text" v-model="requestURL" placeholder="request URL">
          </div>
        </div>

        <div class="field">
          <label class="checkbox">
            <input type="checkbox" v-model="verbose">
            Verbose
          </label>
          <label class="checkbox">
            <input type="checkbox" v-model="insecure">
            Insecure
          </label>
        </div>
      </template>


      <div class="field is-grouped" v-show="canShowGenerateButton">
        <div class="control">
          <button class="is-primary button" @click.self="generateCommand">generate</button>
        </div>
      </div>
    </div>

    <div class="container has-text-centered has-background-dark m-4 p-4" v-if="canShowCommand">
      <button :class="copyButtonClass" @click.self="copyCommand">{{ copyButtonText }}</button>
      <code class="has-background-dark has-text-white is-size-3">$ {{ command }}</code>
      <input id="command" class="hidden" v-model="command"/>
    </div>
  </section>
</template>

<script>
export default {
  name: 'Index',
  data () {
    return {
      proxyTypes: {
        socks5: {
          text: 'SOCKS5',
          validate: () => {
            // TODO: validator
            return true
          },
          generate: () => {
            let command = 'curl'
            if (this.verbose) {
              command += ' -v'
            }
            command += ` --socks5-hostname ${this.proxyHostname} ${this.requestURL}`
            return command
          }
        },
        http: {
          text: 'HTTP',
          validate: () => {
            // TODO: validator
            return true
          },
          generate: () => {
            let command = 'curl'
            if (this.verbose) {
              command += ' -v'
            }
            if (this.insecure) {
              command += ' --proxy-insecure'
            }
            command += ` --proxy ${this.proxyHostname} ${this.requestURL}`
            return command
          }
        }
      },
      insecure: false,
      verbose: false,
      requestURL: '',
      proxyHostname: '',
      proxyType: '0',
      command: '',
      errs: {},
      copied: false
    }
  },
  computed: {
    isSocks5 () {
      return this.proxyType === 'socks5'
    },
    isHTTP () {
      return this.proxyType === 'http'
    },
    canShowGenerateButton () {
      return this.proxyType !== '0'
    },
    canShowCommand () {
      return this.command.length > 0
    },
    copyButtonText () {
      return this.copied ? 'copied' : 'copy'
    },
    copyButtonClass () {
      return this.copied ? 'button is-danger is-light' : 'button is-ghost is-light'
    }
  },
  methods: {
    generateCommand () {
      const proxy = this.proxyTypes[this.proxyType]
      if (!proxy.validate.call(this)) {
        return
      }
      this.command = proxy.generate.call(this)
    },
    copyCommand () {
      // not supported
      if (!document.execCommand) {
        return
      }
      const el = document.getElementById('command')
      if (!el) {
        return
      }
      el.focus()
      el.select()
      document.execCommand('copy')
      this.copied = true
    }
  }
}
</script>
