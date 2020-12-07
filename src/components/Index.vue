<style scope>
.op {
  opacity: 0;
}
</style>
<template>
  <section class="index section">
    <div class="container">
      <div class="field">
        <label class="label">Command</label>
        <div class="control">
          <div class="select">
            <select v-model="commandType">
              <option value="0">Select dropdown</option>
              <option :value="i" :key="i" v-for="(v, i) in commandTypes">{{ v.name }}</option>
            </select>
          </div>
        </div>
        <template v-if="canShowProxyType">
          <div class="field">
            <p class="mt-4">{{ commandTypes[commandType].description }}</p>
          </div>
        </template>
      </div>

      <template v-if="canShowProxyType">
        <div class="field">
          <label class="label">Proxy</label>
          <div class="control">
            <div class="select">
              <select v-model="proxyType">
                <option value="0">Select dropdown</option>
                <option :value="i" :key="i" v-for="(v, i) in commandTypes[commandType].proxyTypes">{{ v.text }}</option>
              </select>
            </div>
          </div>
        </div>
      </template>

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
          <label class="label">Request Port</label>
          <div class="control">
            <input class="input" type="text" v-model="requestPort" placeholder="request port">
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

    <div class="container has-text-centered has-background-dark" v-if="canShowCommand">
      <div class="m-4 p-4">
        <button :disabled="!copySupported" :class="copyButtonClass" @click.self="copyCommand">{{ copyButtonText }}</button>
        <code class="has-background-dark has-text-white is-size-3">$ {{ command }}</code>
      </div>
    </div>
    <input id="command" class="op" v-model="command"/>
  </section>
</template>

<script>
export default {
  name: 'Index',
  data () {
    return {
      insecure: false,
      verbose: false,
      requestPort: '',
      requestURL: '',
      proxyHostname: '',
      proxyType: '0',
      command: '',
      commandType: '0',
      commandTypes: {
        nc: {
          name: 'nc',
          description: 'netcat (often abbreviated to nc) is a computer networking utility for reading from and writing to network connections using TCP or UDP. The command is designed to be a dependable back-end that can be used directly or easily driven by other programs and scripts. At the same time, it is a feature-rich network debugging and investigation tool, since it can produce almost any kind of connection its user could need and has a number of built-in capabilities.',
          proxyTypes: {
            socks5: {
              text: 'SOCKS5',
              validate: () => {
                // TODO: validator
                return true
              },
              generate: () => {
                let command = 'nc'
                command += `  -X 5 -x ${this.proxyHostname} ${this.requestURL} ${this.requestPort}`
                return command
              }
            },
          }
        },
        curl: {
          name: 'curl',
          description: 'cURL (pronounced \'curl\') is a computer software project providing a library (libcurl) and command-line tool (curl) for transferring data using various network protocols. The name stands for "Client URL", which was first released in 1997.',
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
            // TODO: other request method for http
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
          }
        }
      },
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
    canShowProxyType () {
      return this.commandType !== '0'
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
    },
    copySupported () {
      return document.execCommand
    }
  },
  methods: {
    generateCommand () {
      const proxy = this.commandTypes[this.commandType].proxyTypes[this.proxyType]
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
      window.setTimeout(function () {
        this.copied = false
      }.bind(this), 1000)
    }
  }
}
</script>
