import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { message: String }
    
    connect() {
        console.log("Confirm controller connected");
        this.modal = document.getElementById("confirmModal");
        this.triggerForm = null;
    }

    open(event) {
        event.preventDefault();
        console.log("Confirm modal opened!");

        this.triggerForm = event.currentTarget.closest("form");
        console.log("Form found:", this.triggerForm);

        const message = event.currentTarget.dataset.confirmMessageValue;
        if (message) {
            document.getElementById("confirmMessage").textContent = message;
        }
       
        this.modal.classList.remove("hidden");
    }

    confirm() {
        console.log("Confirmed deletion");
        console.log("Form to submit:", this.triggerForm);
        
        if (this.triggerForm) {
            console.log("Form action:", this.triggerForm.action);
            
            this.triggerForm.submit();
        } else {
            console.error("No form found to submit!");
        }
        this.close();
    }
    
    close() {
        this.modal.classList.add("hidden");
        this.triggerForm = null;
    }
}