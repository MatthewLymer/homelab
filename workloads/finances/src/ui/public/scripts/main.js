(function(){
    (function(){
        const ERROR_WAIT_MILLIS = 5_000;

        let lastUpdated = 0;

        function formDataToJson(formData) {
            let object = {};
            formData.forEach((value, key) => {
                if (!Reflect.has(object, key)){
                    object[key] = value;
                    return;
                }
                if (!Array.isArray(object[key])){
                    object[key] = [object[key]];    
                }
                object[key].push(value);
            });

            return JSON.stringify(object);
        };

        function setupListeners() {
            const form = document.querySelector("#awaiting-input-form");

            if (!form) {
                return;
            }

            form.addEventListener('submit', async (event) => {
                event.preventDefault();

                const response = await fetch(form.action, {
                    method: form.method,
                    body: formDataToJson(new FormData(form)),
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                    }
                });

                // if (response.ok) {
                //     statusMessage.textContent = 'Form submitted successfully!';
                //     form.reset(); // Clear the form fields
                // } else {
                //     const errorData = await response.json();
                //     statusMessage.textContent = `Error: ${errorData.message || 'Something went wrong.'}`;
                // }
            });
        };
        
        async function fetchStateTask() {
            for(;;) {
                try {
                    const params = new URLSearchParams({
                        lastUpdated,
                    });

                    const response = await fetch(`/api/state?${params}`);
                    
                    if (!response.ok) {
                        throw new Error(`Unexpected response status: ${response.status}.`);
                    }

                    if (response.status === 204) {
                        continue;
                    }

                    const { htmlContent, lastUpdated: newLastUpdated } = await response.json();

                    const container = document.querySelector("#state-container");

                    if (!container) {
                        throw new Error("State container element not found.");
                    }

                    container.innerHTML = htmlContent;

                    setupListeners();
                    
                    lastUpdated = parseInt(newLastUpdated, 10);
                }
                catch (err) {
                    console.error(err);
                    
                    // delay to prevent overwhelming server
                    await new Promise((resolve) => setTimeout(resolve, ERROR_WAIT_MILLIS));
                }
            }
        }

        fetchStateTask().catch(() => {});
    }());
}());