import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.4";
import { JWT } from "npm:google-auth-library@9.15.1";

type Notice = {
  id: string;
  title: string;
  body: string;
  is_published: boolean;
};

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const firebaseProjectId = Deno.env.get("FIREBASE_PROJECT_ID") ?? "";
const firebaseClientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL") ?? "";
const firebasePrivateKey = (Deno.env.get("FIREBASE_PRIVATE_KEY") ?? "").replace(
  /\\n/g,
  "\n",
);

const supabase = createClient(supabaseUrl, serviceRoleKey);

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const payload = await req.json();
  const notice = (payload.record ?? payload.newRecord ?? payload.notice) as
    | Notice
    | undefined;

  if (!notice?.is_published) {
    return Response.json({ skipped: true });
  }

  const { data: tokens, error } = await supabase
    .from("push_tokens")
    .select("token")
    .not("user_id", "is", null);

  if (error) {
    return Response.json({ error: error.message }, { status: 500 });
  }

  const accessToken = await getAccessToken();
  const results = await Promise.allSettled(
    (tokens ?? []).map(({ token }) =>
      sendMessage(accessToken, token, {
        title: notice.title,
        body: notice.body,
        notice_id: notice.id,
      }).catch(async (error: unknown) => {
        const msg = error instanceof Error ? error.message : String(error);
        // FCM 404/UNREGISTERED: 유효하지 않은 토큰 → DB에서 제거
        if (msg.includes("404") || msg.includes("UNREGISTERED")) {
          await supabase.from("push_tokens").delete().eq("token", token);
        }
        throw error;
      })
    ),
  );

  const sent = results.filter((result) => result.status === "fulfilled").length;
  return Response.json({ sent, failed: results.length - sent });
});

async function getAccessToken() {
  const client = new JWT({
    email: firebaseClientEmail,
    key: firebasePrivateKey,
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });
  const result = await client.getAccessToken();
  if (!result.token) throw new Error("Failed to acquire Firebase access token");
  return result.token;
}

function sendMessage(
  accessToken: string,
  token: string,
  data: Record<string, string>,
) {
  return fetch(
    `https://fcm.googleapis.com/v1/projects/${firebaseProjectId}/messages:send`,
    {
      method: "POST",
      headers: {
        authorization: `Bearer ${accessToken}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: {
            title: data.title,
            body: data.body,
          },
          data,
          android: {
            priority: "HIGH",
            notification: {
              title: data.title,
              body: data.body,
              channel_id: "notices",
              sound: "default",
            },
          },
          apns: {
            headers: {
              "apns-priority": "10",
              "apns-push-type": "alert",
              "apns-topic": "com.sungals.houseMoneyCalculator",
            },
            payload: {
              aps: {
                alert: {
                  title: data.title,
                  body: data.body,
                },
                sound: "default",
              },
            },
          },
        },
      }),
    },
  ).then((response) => {
    if (!response.ok) {
      throw new Error(`FCM failed: ${response.status}`);
    }
    return response.json();
  });
}
