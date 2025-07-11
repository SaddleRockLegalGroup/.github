// flowSpinnerDelayInteraction.js
import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';

export default class FlowSpinnerDelayInteraction extends LightningElement {
    @api delay = 1500; // Delay in milliseconds
    @api navigationAction = 'NEXT'; // 'NEXT' or 'FINISH'

    connectedCallback() {
        setTimeout(() => {
            try {
                if (this.navigationAction === 'FINISH') {
                    this.dispatchEvent(new FlowNavigationFinishEvent());
                } else {
                    this.dispatchEvent(new FlowNavigationNextEvent());
                }
            } catch (err) {
                console.warn('Primary navigation failed, attempting fallback:', err);
                try {
                    if (this.navigationAction === 'NEXT') {
                        this.dispatchEvent(new FlowNavigationFinishEvent());
                    } else {
                        this.dispatchEvent(new FlowNavigationNextEvent());
                    }
                } catch (fallbackErr) {
                    console.error('Fallback navigation also failed:', fallbackErr);
                }
            }
        }, this.delay);
    }
}