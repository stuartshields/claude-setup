<!-- Last updated: 2026-04-23T00:00+11:00 -->

# Input Validation at Trust Boundaries

Every byte that crosses a trust boundary — peer frames, webhook payloads, form posts, file uploads, IPC messages, deserialised caches — is attacker-influenced until proven otherwise. Validate at the decode site, before domain code sees the value.

## Validate at Decode, Not at Domain
- **Size ceiling first, field ranges second.** Cap the raw byte count at the receive layer (e.g. 16 KB for a short-message protocol, 1 MB for a JSON API) *before* invoking a decoder. `JSONDecoder`, `XMLParser`, `Codable`, and friends all allocate proportionally to input — letting them loose on unbounded peer bytes is a DoS vector.
- **Bound every numeric field.** `Int.max` or a negative from a peer will overflow a timer, a sleep, an `UInt64` cast, or an allocator somewhere downstream. Clamp to a policy range at the boundary — defence in depth is cheap, post-hoc forensic work is not.
- **Reject with a typed error.** Validation failures surface as a named `TransportError`/`ValidationError`/domain-specific variant — never a generic `throw` and never a crash.

## Authenticated Identity vs Payload Identity
- **Trust only what the transport authenticated.** The authenticated identity (mTLS cert, signed session token, OS-attested peer, authenticated SSH principal) is the only identity you use for routing, loop guards, or access checks.
- **Payload identity fields are display-only** until signed. `payload.senderId`, `payload.userId`, `payload.from` are attacker-controlled strings. Carry the authenticated identity alongside the payload and use it for every trust decision.

## Length & Charset Discipline
- **Strings have a max length and a charset.** "It's just a name" is how DoS-via-huge-string and XSS-via-exotic-codepoint both enter a system. Bound length (bytes or grapheme clusters — pick deliberately) and restrict the allowed codepoints to what the field actually needs.
- **Collections have a max count.** Lists, maps, and nested structures cap at a documented policy value. Nested structures also cap at a max depth.

## Ordering
- **Validate before persist, before log, before forward.** A malformed value that reaches storage, telemetry, or a downstream peer has escaped the boundary. Reject first, do anything else second.
