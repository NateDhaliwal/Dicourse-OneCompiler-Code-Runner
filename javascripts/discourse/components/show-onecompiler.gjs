import Component from "@glimmer/component";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import { tracked } from '@glimmer/tracking';
import { on } from "@ember/modifier";


export default class ShowOnecompiler extends Component {
  @tracked modalIsVisible;
  @tracked codeLang;
  @tracked code;

  get getCode() {
    const response = this.args.post.cooked;
    if (response.includes("<pre")) {
      this.codeLang = response.split('<pre data-code-wrap="')[1].split('"')[0];
      
      if (response.includes("lang-auto")) {
        this.code = response.replace("<pre>", "").replace("</pre>", "").split("</code>")[0].replace('<code class="lang-auto">', "");
      } else {
        this.code = response.replace(`<pre data-code-wrap="${this.codeLang}">`, "").replace("</pre>", "").split("</code>")[0].replace(`<code class="lang-${this.codeLang}">`, "");
      }

    }
    return response;
  } 
  
  @action
  showModal() {
    this.modalIsVisible = true;
    return;
  }

  @action
  hideModal() {
    this.modalIsVisible = false;
    return;
  }

  @action
  onIframeLoaded() {
    let iFrame = document.getElementById('oc-editor');
    iFrame.contentWindow.postMessage({
      eventType: 'populateCode',
      language: "{{this.codeLang}}",
      files: [
        {
          "name": "file.{{this.codeLang}}",
          "content": "{{this.codeLang}}"
        }
      ]
    }, "*");
    return;
  }


  <template>
    <DButton
      @translatedLabel="Show Modal"
      @action={{this.showModal}}
    />

    {{#if this.modalIsVisible}}
      <DModal @title="Code Compiler" @closeModal={{this.hideModal}}>
        <p>Code: {{this.getCode}}</p>
        <iframe
          frameBorder="0"
          height="450px"  
          src="https://onecompiler.com/embed/{{this.codeLang}}?listenToEvents=true" 
          width="100%"
          id="oc-editor"
          title="OneCompiler Code Editor"
          {{on "load" this.onIframeLoaded}}>
        </iframe>
      </DModal>
    {{/if}}
  </template>
}
