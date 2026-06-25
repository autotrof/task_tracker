# API Reference For Flutter

Dokumen ini berisi contoh request dan response untuk acuan integrasi Flutter ke backend `Task Tracker API`.

Base URL local Docker:

```text
http://localhost:8080/api
```

Status task yang valid:

- `pending`
- `done`

## 1. Ambil Daftar Task

Endpoint:

```text
GET /tasks
```

Contoh request:

```bash
curl --request GET \
  --url 'http://localhost:8080/api/tasks?per_page=10&search=backend&status=pending&sort_by=created_at&sort_direction=desc' \
  --header 'Accept: application/json'
```

Query parameter yang didukung:

- `per_page` opsional, minimum `1`, maksimum `100`
- `search` opsional, mencari task berdasarkan `title`
- `status` opsional, nilai yang didukung: `pending`, `done`
- `sort_by` opsional, nilai yang didukung: `title`, `created_at`
- `sort_direction` opsional, nilai yang didukung: `asc`, `desc`

Contoh response sukses `200 OK`:

```json
{
  "data": [
    {
      "id": 1,
      "title": "Belajar Riverpod",
      "description": "Pelajari state management untuk halaman daftar task.",
      "status": "pending",
      "created_at": "2026-06-25T01:40:00.000000Z",
      "updated_at": "2026-06-25T01:40:00.000000Z"
    },
    {
      "id": 2,
      "title": "Sambungkan API detail",
      "description": "Tampilkan detail task saat item dipilih.",
      "status": "done",
      "created_at": "2026-06-25T01:42:00.000000Z",
      "updated_at": "2026-06-25T01:50:00.000000Z"
    }
  ],
  "links": {
    "first": "http://localhost:8080/api/tasks?page=1",
    "last": "http://localhost:8080/api/tasks?page=1",
    "prev": null,
    "next": null
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 1,
    "links": [
      {
        "url": null,
        "label": "&laquo; Previous",
        "page": null,
        "active": false
      },
      {
        "url": "http://localhost:8080/api/tasks?page=1",
        "label": "1",
        "page": 1,
        "active": true
      },
      {
        "url": null,
        "label": "Next &raquo;",
        "page": null,
        "active": false
      }
    ],
    "path": "http://localhost:8080/api/tasks",
    "per_page": 10,
    "to": 2,
    "total": 2
  }
}
```

Contoh response saat data kosong `200 OK`:

```json
{
  "data": [],
  "links": {
    "first": "http://localhost:8080/api/tasks?page=1",
    "last": "http://localhost:8080/api/tasks?page=1",
    "prev": null,
    "next": null
  },
  "meta": {
    "current_page": 1,
    "from": null,
    "last_page": 1,
    "links": [
      {
        "url": null,
        "label": "&laquo; Previous",
        "page": null,
        "active": false
      },
      {
        "url": "http://localhost:8080/api/tasks?page=1",
        "label": "1",
        "page": 1,
        "active": true
      },
      {
        "url": null,
        "label": "Next &raquo;",
        "page": null,
        "active": false
      }
    ],
    "path": "http://localhost:8080/api/tasks",
    "per_page": 15,
    "to": null,
    "total": 0
  }
}
```

## 2. Ambil Detail Task

Endpoint:

```text
GET /tasks/{id}
```

Contoh request:

```bash
curl --request GET \
  --url 'http://localhost:8080/api/tasks/1' \
  --header 'Accept: application/json'
```

Contoh response sukses `200 OK`:

```json
{
  "data": {
    "id": 1,
    "title": "Belajar Riverpod",
    "description": "Pelajari state management untuk halaman daftar task.",
    "status": "pending",
    "created_at": "2026-06-25T01:40:00.000000Z",
    "updated_at": "2026-06-25T01:40:00.000000Z"
  }
}
```

Contoh response jika task tidak ditemukan `404 Not Found`:

```json
{
  "message": "No query results for model [App\\Models\\Task] 999999"
}
```

## 3. Tambah Task

Endpoint:

```text
POST /tasks
```

Contoh request:

```bash
curl --request POST \
  --url 'http://localhost:8080/api/tasks' \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{
    "title": "Hubungkan halaman create task",
    "description": "Kirim form tambah task ke backend.",
    "status": "pending"
  }'
```

Contoh request paling sederhana:

```json
{
  "title": "Hubungkan halaman create task",
  "description": "Kirim form tambah task ke backend."
}
```

Catatan:

- `title` wajib diisi
- `description` wajib diisi
- `status` opsional
- jika `status` tidak dikirim, backend akan mengisi `pending`

Contoh response sukses `201 Created`:

```json
{
  "data": {
    "id": 3,
    "title": "Hubungkan halaman create task",
    "description": "Kirim form tambah task ke backend.",
    "status": "pending",
    "created_at": "2026-06-25T02:00:00.000000Z",
    "updated_at": "2026-06-25T02:00:00.000000Z"
  }
}
```

Contoh response validasi gagal `422 Unprocessable Entity`:

```json
{
  "message": "The title field is required. (and 1 more error)",
  "errors": {
    "title": [
      "The title field is required."
    ],
    "description": [
      "The description field is required."
    ]
  }
}
```

## 4. Ubah Status Task

Endpoint:

```text
PATCH /tasks/{id}
```

Contoh request:

```bash
curl --request PATCH \
  --url 'http://localhost:8080/api/tasks/3' \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{
    "status": "done"
  }'
```

Contoh request body:

```json
{
  "status": "done"
}
```

Contoh response sukses `200 OK`:

```json
{
  "data": {
    "id": 3,
    "title": "Hubungkan halaman create task",
    "description": "Kirim form tambah task ke backend.",
    "status": "done",
    "created_at": "2026-06-25T02:00:00.000000Z",
    "updated_at": "2026-06-25T02:05:00.000000Z"
  }
}
```

Contoh response validasi gagal `422 Unprocessable Entity`:

```json
{
  "message": "The selected status is invalid.",
  "errors": {
    "status": [
      "The selected status is invalid."
    ]
  }
}
```

## 5. Ringkasan Untuk Mapping Di Flutter

Field task:

```json
{
  "id": 1,
  "title": "Belajar Riverpod",
  "description": "Pelajari state management untuk halaman daftar task.",
  "status": "pending",
  "created_at": "2026-06-25T01:40:00.000000Z",
  "updated_at": "2026-06-25T01:40:00.000000Z"
}
```

Field pagination utama:

```json
{
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 10,
    "total": 2
  }
}
```

Saran pemakaian di Flutter:

- pakai `data` sebagai daftar utama atau detail object
- pakai `meta.current_page`, `meta.last_page`, dan `links.next` untuk pagination
- pakai `errors` untuk menampilkan pesan validasi form
