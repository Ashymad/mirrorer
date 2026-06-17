/**
 * Welcome to Cloudflare Workers!
 *
 * This is a template for a Scheduled Worker: a Worker that can run on a
 * configurable interval:
 * https://developers.cloudflare.com/workers/platform/triggers/cron-triggers/
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Run `curl "http://localhost:8787/__scheduled?cron=*+*+*+*+*"` to see your Worker in action
 * - Run `npm run deploy` to publish your Worker
 *
 * Bind resources to your Worker in `wrangler.jsonc`. After adding bindings, a type definition for the
 * `Env` object can be regenerated with `npm run cf-typegen`.
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

export default {
    async fetch(req) {
        return new Response(`I am just a humble cloudflare worker :)`);
    },
    async scheduled(event, env, ctx) {
        let yml_req = await fetch("https://git.sr.ht/query", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${env.SRHTTOKEN}`
            },
            body: JSON.stringify({
                "query": `{
                    me {
                        repository(name: "mirrorer") {
                            path(path: ".build.yml") {
                                object {
                                    ... on TextBlob {
                                        text
                                    }
                                }
                            }
                        }
                    }
                }`
            })
        });
        let yml_json = await yml_req.json();
        let yml = yml_json.data.me.repository.path.object.text;
        let job_req = await fetch("https://builds.sr.ht/query", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${env.SRHTTOKEN}`
            },
            body: JSON.stringify({
                "query": `mutation ($yml: String!) {
                    submit(manifest: $yml) {
                        id
                    }
                }`,
                "variables": {
                    "yml": yml
                }})
        });
        console.log(`Build submitted at ${event.cron}: ${JSON.stringify(await job_req.json())}`);
    }
} satisfies ExportedHandler<Env>;
