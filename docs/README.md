# Global Marketplace Platform — সহজ বাংলা ডকুমেন্টেশন

এই ডকুমেন্টটা নতুন ডেভেলপার ও নতুন ডেভঅপসদের জন্য লেখা। এখানে সহজ ভাষায় বলা হয়েছে এই অ্যাপ কী করে, কোন কোন ফাইল/ফোল্ডার কী কাজ করে, আর কীভাবে পুরো সিস্টেম রান হয়।

## ১) এই অ্যাপটা কী করে
এটা একটি ই‑কমার্স মাইক্রোসার্ভিস সিস্টেম। কাজগুলো ভাগ করে করা হয়:
- **API Gateway** সব রিকোয়েস্টের প্রধান দরজা।
- **Domain Services** (Catalog, Orders, Payments ইত্যাদি) আলাদা আলাদা ফিচার হ্যান্ডেল করে।
- **Data Layer** (Postgres, Redis, OpenSearch) ডেটা রাখে ও দ্রুত খুঁজে দেয়।
- **Event Layer** (Kafka, Kafka Connect) ডেটা পরিবর্তনের ইভেন্ট স্ট্রিম করে।
- **AI Service** (Transformer API) টেক্সটের sentiment বা শ্রেণি নির্ধারণ করে।
- **Kubernetes + Docker** দিয়ে পুরো সিস্টেম ডিপ্লয় ও স্কেল করা হয়।

## ২) মূল আর্কিটেকচার (খুব সহজ ভাষায়)
1. ইউজার বা ফ্রন্টএন্ড → API Gateway
2. API Gateway → সংশ্লিষ্ট সার্ভিস (Catalog/Orders/Payments)
3. সার্ভিসগুলো → ডেটা স্টোরেজ (Postgres/Redis/OpenSearch)
4. ডেটা পরিবর্তন হলে → Kafka ইভেন্ট তৈরি
5. Kafka Connect → ইভেন্টগুলোকে S3/MinIO তে পাঠায়
6. AI সার্ভিস → টেক্সট বিশ্লেষণ করে ফল দেয়

## ২.১) আর্কিটেকচার ডায়াগ্রাম (টেক্সট ভিউ)
Browser/Frontend
  ↓
API Gateway (services/api-gateway)
  ↓
Domain Services (catalog, orders, payments, search...)
  ↓
Postgres / Redis / OpenSearch
  ↓
Kafka (events) → Kafka Connect → MinIO (S3)
  ↓
Analytics/AI ব্যবহার করে রিপোর্ট বা ইনসাইট

## ২.২) ডেটা ফ্লো (কীভাবে তথ্য চলে)
1. ইউজার রিকোয়েস্ট আসে → API Gateway
2. API Gateway রাউট অনুযায়ী সঠিক সার্ভিসে পাঠায়
3. সার্ভিস ডেটা পড়া/লেখা করে → Postgres বা Redis
4. ডেটা পরিবর্তন হলে → Kafka তে ইভেন্ট যায়
5. Kafka Connect → ইভেন্ট ফাইল আকারে MinIO তে রাখে
6. পরবর্তীতে Analytics/AI সার্ভিস এই ডেটা ব্যবহার করতে পারে

## ২.৩) কেন Microservices আর্কিটেকচার
- প্রতিটি টিম আলাদা সার্ভিসে কাজ করতে পারে
- একটি সার্ভিসে সমস্যা হলেও অন্যগুলো চলে
- স্কেলিং সহজ (যে সার্ভিসে লোড বেশি শুধু সেটাই বাড়ানো যায়)

## ২.৪) API Gateway কীভাবে কাজ করে
- এটি রিভার্স‑প্রক্সি মতো কাজ করে
- ইনকামিং রিকোয়েস্ট নিয়ে সঠিক সার্ভিসে ফরওয়ার্ড করে
- উদাহরণ: `/ai/infer` গেলে transformer API তে পাঠায়
ফাইল: services/api-gateway/src/app.js

## ৩) ফোল্ডার ম্যাপ (সবচেয়ে গুরুত্বপূর্ণ)
- **services/** → সব ব্যাকএন্ড মাইক্রোসার্ভিস
- **frontend/** → ওয়েব ফ্রন্টএন্ড (Next.js)
- **platform/k8s/** → Kubernetes ডিপ্লয়মেন্ট ফাইল
- **infra/** → ইনফ্রা সেটআপ (Terraform, Kafka Connect)
- **ml/** → AI/ML ট্রেনিং স্ক্রিপ্ট
- **docker-compose.yml** → লোকাল ডেভেলপমেন্ট রান

## ৪) services/ — প্রতিটা সার্ভিস কী করে
প্রতিটি সার্ভিসে সাধারণত এই ফাইল থাকে:
- **src/app.js** → রাউট ও API লজিক
- **src/server.js** → সার্ভার স্টার্ট করে
- **Dockerfile** → কন্টেইনার ইমেজ বানায়
- **package.json** → ডিপেন্ডেন্সি ও স্ক্রিপ্ট

উদাহরণ সার্ভিস:
- **api-gateway** → সব রিকোয়েস্ট ফরওয়ার্ড করে
- **catalog** → প্রোডাক্ট তালিকা দেখায়
- **orders** → অর্ডার তৈরি ও তালিকা
- **payments** → পেমেন্ট ফ্লো (ডেমো)
- **search** → সার্চ রেজাল্ট

## ৪.১) সার্ভিস স্ট্যান্ডার্ড রাউট
প্রতিটি সার্ভিসে সাধারণত থাকে:
- `/health` → সার্ভিস সুস্থ কি না
- `/ready` → সার্ভিস রেডি কি না
- `/startup` → স্টার্ট হয়েছে কি না
- `/ping` → দ্রুত কনফার্ম

এগুলো মনিটরিং ও ডিপ্লয়মেন্টে গুরুত্বপূর্ণ।

## ৫) AI সার্ভিস (Transformer API) কী করে
এই সার্ভিস টেক্সট ইনপুট নেয় এবং বলে দেয় সেটা POSITIVE/NEGATIVE।
- ফাইল: **services/transformer-api/app.py**
- লাইব্রেরি: **PyTorch + HuggingFace Transformers + FastAPI**
- Endpoint:
  - `POST /infer` → একক টেক্সট
  - `POST /infer/batch` → একাধিক টেক্সট

এটি প্রোডাক্টে কেন দরকার?
- ইউজার রিভিউ বিশ্লেষণ
- কনটেন্ট মডারেশন
- সার্চ/রেকমেন্ডেশন উন্নত করা

## ৫.১) AI সার্ভিসের ভিতরের টেকনিক্যাল ধাপ
1. টেক্সট → Tokenizer → সংখ্যায় রূপান্তর
2. Model logits দেয়
3. Softmax দিয়ে probability বের হয়
4. সবচেয়ে বেশি probability‑র লেবেল আউটপুট হয়

এগুলোই Transformers‑এর বেসিক inference flow।

## ৬) ML ট্রেনিং ফোল্ডার
- **ml/transformer-training/train.py** → ছোট ডেমো ট্রেনিং
- **requirements.txt** → ট্রেনিং লাইব্রেরি

এখানে HuggingFace dataset থেকে ছোট ডেটা নিয়ে মডেল টিউন করা হয়। তারপর সেই মডেল সার্ভিসে ব্যবহার করা যায়।

## ৭) docker-compose.yml কী করে
লোকাল ডেভেলপমেন্টে সব সার্ভিস একসাথে চালাতে এটি ব্যবহার হয়।
- প্রতিটি সার্ভিসের **build context** দেয়া থাকে
- **ports** দিয়ে লোকাল পোর্ট ম্যাপ করা হয়
- **environment** দিয়ে কনফিগ দেয়া হয়

## ৭.১) Dockerfile কেন দরকার
- কোডকে runnable container বানায়
- সব ডিপেন্ডেন্সি একইভাবে ইনস্টল হয়
- লোকাল ও প্রোডাকশন দুই জায়গায় একই পরিবেশ পাওয়া যায়

## ৮) Kubernetes (platform/k8s)
এখানে সব মাইক্রোসার্ভিসের ডিপ্লয়মেন্ট ও সার্ভিস ফাইল আছে।
- **base/** → সব সার্ভিসের মূল ডিপ্লয়মেন্ট
- **overlays/dev** → ডেভ এনভে replica কম
- **overlays/prod** → প্রোডাকশনে replica বেশি

## ৮.১) Kubernetes এ কী কী থাকে
- Deployment → কতগুলো pod চলবে
- Service → নেটওয়ার্ক endpoint দেয়
- ConfigMap/Secret → কনফিগ এবং সিক্রেট রাখে

এইগুলো মিলিয়ে production‑ready deployment তৈরি হয়।

## ৯) Infra ফোল্ডার (infra/)
এখানে আছে:
- **Terraform modules** → ক্লাউড ইনফ্রা তৈরি (VPC, OKE, Object Storage)
- **Kafka Connect config** → Debezium + S3 sink কনফিগ

## ৯.১) Debezium কী করে
Postgres এ ডেটা পরিবর্তন হলে Debezium সেটাকে Kafka ইভেন্টে রূপ দেয়।
এইভাবেই CDC (Change Data Capture) হয়।

## ৯.২) S3 Sink কী করে
Kafka topic থেকে ইভেন্ট পড়ে MinIO/S3 তে ফাইল আকারে জমা রাখে।
এটা ডেটা লেক/আর্কাইভের কাজে লাগে।

## ১০) কীভাবে রান করবেন (লোকাল)
1. Docker চালু করুন  
2. সব সার্ভিস:
   - `docker compose up --build`
3. API Gateway হেলথ:
   - `http://localhost:9000/health`
4. AI সার্ভিস ইনফারেন্স:
   - `http://localhost:9017/infer`

## ১১) টেস্টিং (সাধারণ ধারণা)
এই রিপোতে প্রধানত লিন্ট ও সার্ভিস টেস্ট আছে।
- `npm run lint` → ব্যাকএন্ড lint
- `frontend` ফোল্ডারে গিয়ে `npm run lint` → ফ্রন্টএন্ড lint
- `make test` → সব সার্ভিসের jest টেস্ট (সময় বেশি লাগতে পারে)

## ১১.১) CI/CD ধারণা (সাধারণ ভাষায়)
- GitHub Actions দিয়ে লিন্ট ও টেস্ট চালানো হয়
- ডিপ্লয় আলাদা workflow দিয়ে করা যায়
এতে কোড কোয়ালিটি বজায় থাকে।

## ১২) সার্ভিসগুলোর সহজ ফ্লো (চোখে দেখার মতো)
1. ইউজার ব্রাউজার → API Gateway
2. API Gateway → catalog/orders/search সার্ভিস
3. সার্ভিস → Postgres/Redis/OpenSearch
4. ডেটা পরিবর্তন → Kafka ইভেন্ট
5. Kafka Connect → S3/MinIO তে ইভেন্ট ডাম্প
6. AI সার্ভিস → টেক্সট বিশ্লেষণ করে রেজাল্ট দেয়

## ১২.১) প্রোডাক্টে এই আর্কিটেকচারের বাস্তব ব্যবহার
- Orders/Payments ডেটা ট্র্যাক
- রিভিউগুলোতে sentiment স্কোর
- Search রেজাল্ট উন্নত করা
- Analytics রিপোর্ট তৈরি

## ১৩) নতুন ডেভেলপার/ডেভঅপসদের জন্য টিপস
- আগে **docker-compose** দিয়ে সব রান করে নিন
- তারপর **platform/k8s** পড়ুন
- API Gateway হচ্ছে শুরু করার সবচেয়ে ভালো জায়গা
- AI সার্ভিস ছোট হলেও বাস্তব প্রোডাক্টে খুব কাজে লাগে
