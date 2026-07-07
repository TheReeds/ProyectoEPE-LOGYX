# Guía de Arquitectura y Desarrollo Frontend — LOGYX
> Angular 22 · Tailwind CSS v4 · PrimeNG 21 · pnpm  
> **Uso:** leer este documento al inicio de cada sesión antes de tocar código frontend.

---

## 1. Stack y versiones instaladas

| Paquete | Versión | Ubicación |
|---------|---------|-----------|
| `@angular/core` | 22.0.4 | `Proyecto/frontend/logyx-web` |
| `tailwindcss` | 4.3.2 | devDependency |
| `@tailwindcss/postcss` | 4.3.2 | devDependency |
| `primeng` | 21.1.9 | dependency |
| `@primeng/themes` | 21.0.4 | dependency |
| `@angular/animations` | 22.0.4 | dependency (requerido por PrimeNG) |
| `pnpm` | 10.33 | gestor de paquetes — NO usar npm/yarn |
| `ng` (CLI) | 22.0.4 | `~/.local/share/pnpm/ng` |

**Comandos de desarrollo:**
```bash
cd Proyecto/frontend/logyx-web
ng serve          # dev server :4200
ng build          # build producción
ng g c features/pyme/nueva-pantalla/nombre  # generar componente
```

---

## 2. Reglas Angular 22 — lo que NUNCA se escribe

```typescript
// ❌ NUNCA — standalone es default desde v20
@Component({ standalone: true, ... })

// ❌ NUNCA — OnPush es default desde v22
@Component({ changeDetection: ChangeDetectionStrategy.OnPush, ... })

// ❌ NUNCA — usar inject() en su lugar
constructor(private http: HttpClient) {}

// ❌ NUNCA — usar input()/output()
@Input() valor!: string;
@Output() cambio = new EventEmitter();

// ❌ NUNCA — usar [class] binding directo
[ngClass]="{ 'activo': condicion }"
[ngStyle]="{ color: valor }"

// ❌ NUNCA — usar control flow nativo
*ngIf="condicion"
*ngFor="let x of lista"
*ngSwitch

// ❌ NUNCA — usar host object en el decorator
@HostBinding('class.activo') isActive = false;
@HostListener('click') onClick() {}
```

---

## 3. Reglas Angular 22 — lo que SIEMPRE se escribe

```typescript
// ✅ Standalone implícito — no se declara
@Component({ selector: 'app-foo', imports: [...], template: `...` })
export class FooComponent {}

// ✅ inject() para inyección de dependencias
export class MiServicio {
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly auth = inject(AuthService);
}

// ✅ input() y output() como señales
export class CardComponent {
  readonly title  = input.required<string>();
  readonly score  = input<number>(0);
  readonly select = output<string>();
}

// ✅ Control flow nativo en templates
@if (loading()) {
  <p-skeleton />
} @else {
  <div>contenido</div>
}

@for (item of items(); track item.id) {
  <div>{{ item.name }}</div>
} @empty {
  <p>Sin resultados</p>
}

@switch (status()) {
  @case ('OPEN')      { <span class="text-green-600">Abierto</span> }
  @case ('CLOSED')    { <span class="text-gray-400">Cerrado</span> }
  @default            { <span>-</span> }
}

// ✅ host object en el decorator
@Component({
  host: { '(click)': 'onClick()', '[class.activo]': 'isActive()' }
})

// ✅ [class] binding en lugar de ngClass
<div [class]="condicion ? 'bg-blue-500' : 'bg-gray-200'">

// ✅ [class.nombre] para toggle individual
<div [class.font-bold]="esActivo()" [class.text-red-500]="hayError()">
```

---

## 4. Signals — patrones de uso

```typescript
// Estado local en componentes
export class MiComponent {
  // señales de estado
  readonly items   = signal<ShipmentRequest[]>([]);
  readonly loading = signal(false);
  readonly error   = signal<string | null>(null);
  readonly query   = signal('');

  // señal derivada (computed — NO usar funciones separadas para esto)
  readonly filtrados = computed(() =>
    this.items().filter(i =>
      i.origin.city.toLowerCase().includes(this.query().toLowerCase())
    )
  );

  // efecto para side effects (llamadas HTTP, logs, etc.)
  constructor() {
    effect(() => {
      if (this.error()) console.error(this.error());
    });
  }

  // mutar señales: set/update, NUNCA mutate
  agregarItem(item: ShipmentRequest): void {
    this.items.update(prev => [...prev, item]);   // ✅
    // this.items.mutate(l => l.push(item));      // ❌ eliminado en v18+
  }
}

// Señales de solo lectura expuestas desde servicios
@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly _profile = signal<Profile | null>(null);
  readonly profile = this._profile.asReadonly();      // componentes no pueden mutar
  readonly isAuthenticated = computed(() => !!this._profile());
}
```

---

## 5. Signal Forms (Angular 22 — estables)

Signal Forms reemplazan a Reactive Forms para formularios nuevos:

```typescript
import { Component, inject } from '@angular/core';
import { FormBuilder } from '@angular/forms/signals';  // ← importar de /signals
import { Validators } from '@angular/forms';

@Component({
  selector: 'app-login',
  imports: [/* PrimeNG components */],
  template: `
    <form (ngSubmit)="submit()">
      <p-inputtext
        [value]="form.controls.email.value()"
        (input)="form.controls.email.setValue($any($event.target).value)" />
      @if (form.controls.email.errors()?.['required']) {
        <small class="text-red-500">Email requerido</small>
      }
      <p-button type="submit" label="Ingresar" [disabled]="form.invalid()" />
    </form>
  `
})
export class LoginFormComponent {
  private readonly fb = inject(FormBuilder);

  readonly form = this.fb.group({
    email:    this.fb.control('', [Validators.required, Validators.email]),
    password: this.fb.control('', [Validators.required, Validators.minLength(8)])
  });

  submit(): void {
    if (this.form.invalid()) return;
    const { email, password } = this.form.value();
    // llamar al servicio...
  }
}
```

---

## 6. Servicios — patrón estándar

```typescript
import { Injectable, inject, signal, computed } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { ShipmentRequest, PageResponse } from '../models';
import { ApiService } from './api.service';

@Injectable({ providedIn: 'root' })
export class ShipmentService {
  private readonly api = inject(ApiService);

  private readonly _requests = signal<ShipmentRequest[]>([]);
  readonly requests = this._requests.asReadonly();

  load(): Observable<PageResponse<ShipmentRequest>> {
    return this.api.get<PageResponse<ShipmentRequest>>('/shipment-requests').pipe(
      tap(res => this._requests.set(res.data))
    );
  }

  create(dto: CreateShipmentRequest): Observable<ShipmentRequest> {
    return this.api.post<ShipmentRequest>('/shipment-requests', dto).pipe(
      tap(created => this._requests.update(prev => [...prev, created]))
    );
  }
}
```

---

## 7. Componentes — patrón estándar

```typescript
import { Component, inject, signal, computed, OnInit } from '@angular/core';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { TagModule } from 'primeng/tag';
import { ShipmentRequest } from '../../../core/models';
import { ShipmentService } from '../../../core/services/shipment.service';

@Component({
  selector: 'app-requests',
  imports: [TableModule, ButtonModule, TagModule],   // ← imports explícitos, no NgModule
  templateUrl: './requests.html'
  // Sin styleUrl si solo usa Tailwind
})
export class RequestsComponent implements OnInit {
  private readonly shipmentSvc = inject(ShipmentService);

  readonly requests = this.shipmentSvc.requests;
  readonly loading  = signal(false);

  ngOnInit(): void {
    this.loading.set(true);
    this.shipmentSvc.load().subscribe({
      complete: () => this.loading.set(false),
      error:    () => this.loading.set(false)
    });
  }
}
```

---

## 8. Imports de Angular — de dónde viene cada cosa

```typescript
// Core Angular
import { Component, Injectable, Directive, Pipe }    from '@angular/core';
import { inject, signal, computed, effect, input, output } from '@angular/core';
import { OnInit, OnDestroy, AfterViewInit }           from '@angular/core';

// Router
import { Router, ActivatedRoute, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { CanActivateFn, Routes }                      from '@angular/router';

// HTTP
import { HttpClient, HttpInterceptorFn }              from '@angular/common/http';
import { provideHttpClient, withFetch, withInterceptors } from '@angular/common/http';

// Forms (Signal Forms — USAR ESTO)
import { FormBuilder }   from '@angular/forms/signals';
import { Validators }    from '@angular/forms';

// Async pipe (para Observables en templates)
import { AsyncPipe }     from '@angular/common';

// Imágenes optimizadas
import { NgOptimizedImage } from '@angular/common';

// RxJS
import { Observable, Subject, takeUntilDestroyed } from 'rxjs';
import { tap, map, catchError, switchMap, debounceTime } from 'rxjs/operators';

// takeUntilDestroyed — reemplaza ngOnDestroy para unsubscribe automático
export class MiComponent {
  private readonly destroyRef = inject(DestroyRef);

  ngOnInit(): void {
    this.servicio.data$.pipe(
      takeUntilDestroyed(this.destroyRef)  // ✅ sin ngOnDestroy manual
    ).subscribe(...);
  }
}
```

---

## 9. Imports de PrimeNG — módulos por componente

Cada componente de PrimeNG se importa de su propio path. **Nunca importar `PrimeNGModule` completo.**

```typescript
// Inputs y Formularios
import { InputTextModule }     from 'primeng/inputtext';
import { InputNumberModule }   from 'primeng/inputnumber';
import { TextareaModule }      from 'primeng/textarea';
import { DropdownModule }      from 'primeng/dropdown';      // Select
import { SelectModule }        from 'primeng/select';        // Select nuevo (v21+)
import { MultiSelectModule }   from 'primeng/multiselect';
import { CalendarModule }      from 'primeng/calendar';      // Date picker
import { CheckboxModule }      from 'primeng/checkbox';
import { RadioButtonModule }   from 'primeng/radiobutton';
import { ToggleSwitchModule }  from 'primeng/toggleswitch';
import { FileUploadModule }    from 'primeng/fileupload';

// Botones y acciones
import { ButtonModule }        from 'primeng/button';
import { SplitButtonModule }   from 'primeng/splitbutton';

// Datos
import { TableModule }         from 'primeng/table';         // DataTable
import { DataViewModule }      from 'primeng/dataview';
import { PaginatorModule }     from 'primeng/paginator';
import { TreeTableModule }     from 'primeng/treetable';

// Visualización
import { ChartModule }         from 'primeng/chart';         // Chart.js wrapeado
import { TimelineModule }      from 'primeng/timeline';      // Historial de estados
import { TagModule }           from 'primeng/tag';           // Badges de estado
import { BadgeModule }         from 'primeng/badge';
import { AvatarModule }        from 'primeng/avatar';
import { ProgressBarModule }   from 'primeng/progressbar';
import { KnobModule }          from 'primeng/knob';          // Score circular
import { MeterGroupModule }    from 'primeng/metergroup';

// Overlays y diálogos
import { DialogModule }        from 'primeng/dialog';
import { DrawerModule }        from 'primeng/drawer';        // Sidebar deslizable
import { OverlayPanelModule }  from 'primeng/overlaypanel';
import { TooltipModule }       from 'primeng/tooltip';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { ToastModule }         from 'primeng/toast';         // Notificaciones toast

// Layout y contenedores
import { CardModule }          from 'primeng/card';
import { PanelModule }         from 'primeng/panel';
import { AccordionModule }     from 'primeng/accordion';
import { TabsModule }          from 'primeng/tabs';          // Pestañas (v21+ unificado)
import { StepperModule }       from 'primeng/stepper';       // Wizards / onboarding
import { DividerModule }       from 'primeng/divider';

// Carga y estados vacíos
import { SkeletonModule }      from 'primeng/skeleton';
import { ProgressSpinnerModule } from 'primeng/progressspinner';

// Servicios PrimeNG (inyectables)
import { MessageService }      from 'primeng/api';           // para Toast
import { ConfirmationService } from 'primeng/api';           // para ConfirmDialog
```

---

## 10. Uso de PrimeNG — ejemplos clave del proyecto

### DataTable (Marketplace, solicitudes, flota)
```typescript
imports: [TableModule, TagModule, ButtonModule]
```
```html
<p-table
  [value]="requests()"
  [loading]="loading()"
  [paginator]="true"
  [rows]="10"
  [rowsPerPageOptions]="[10, 25, 50]"
  [globalFilterFields]="['origin.city', 'destination.city', 'cargoType']"
  styleClass="p-datatable-sm">

  <ng-template #caption>
    <p-iconfield>
      <p-inputicon styleClass="pi pi-search" />
      <input pInputText type="text" (input)="dt.filterGlobal($any($event.target).value, 'contains')" placeholder="Buscar..." />
    </p-iconfield>
  </ng-template>

  <ng-template #header>
    <tr>
      <th pSortableColumn="origin.city">Origen <p-sortIcon field="origin.city" /></th>
      <th pSortableColumn="destination.city">Destino <p-sortIcon field="destination.city" /></th>
      <th>Estado</th>
      <th></th>
    </tr>
  </ng-template>

  <ng-template #body let-req>
    <tr>
      <td>{{ req.origin.city }}</td>
      <td>{{ req.destination.city }}</td>
      <td><p-tag [value]="req.status" [severity]="getSeverity(req.status)" /></td>
      <td><p-button label="Ver" size="small" (onClick)="ver(req)" /></td>
    </tr>
  </ng-template>
</p-table>
```

### Toast (notificaciones)
```typescript
// app.config.ts — agregar provider
import { MessageService } from 'primeng/api';
providers: [ MessageService ]

// En el componente
imports: [ToastModule]
private readonly msg = inject(MessageService);

this.msg.add({ severity: 'success', summary: 'Oferta enviada', detail: 'El transportista fue notificado' });
this.msg.add({ severity: 'error',   summary: 'Error', detail: 'No se pudo enviar la oferta' });
```
```html
<p-toast />   <!-- una sola vez en main-layout.html -->
```

### Tag / Badge de estado (StatusBadge compartido)
```typescript
// Mapeado de estados → severity de PrimeNG
function statusSeverity(s: ShipmentRequestStatus): string {
  const map: Record<ShipmentRequestStatus, string> = {
    OPEN:       'info',
    IN_AUCTION: 'warn',
    MATCHED:    'success',
    IN_TRANSIT: 'contrast',
    DELIVERED:  'success',
    CANCELLED:  'danger'
  };
  return map[s] ?? 'secondary';
}
```
```html
<p-tag [value]="item.status" [severity]="statusSeverity(item.status)" />
```

### Timeline (historial de envío / tracking)
```typescript
imports: [TimelineModule, CardModule]
```
```html
<p-timeline [value]="stops()" align="left">
  <ng-template #content let-stop>
    <div class="text-sm font-semibold">{{ stop.location.address }}</div>
    <div class="text-xs text-gray-500">{{ stop.eta | date:'dd/MM HH:mm' }}</div>
  </ng-template>
  <ng-template #opposite let-stop>
    <p-tag [value]="stop.status" [severity]="stopSeverity(stop.status)" />
  </ng-template>
</p-timeline>
```

### Dialog / Drawer
```typescript
imports: [DialogModule]

readonly dialogVisible = signal(false);
```
```html
<p-button label="Ofertar" (onClick)="dialogVisible.set(true)" />

<p-dialog
  [(visible)]="dialogVisible"
  header="Enviar oferta"
  [modal]="true"
  [style]="{ width: '480px' }">
  <!-- contenido del form -->
  <ng-template #footer>
    <p-button label="Cancelar" severity="secondary" (onClick)="dialogVisible.set(false)" />
    <p-button label="Confirmar" (onClick)="confirmar()" />
  </ng-template>
</p-dialog>
```

### ConfirmDialog
```typescript
imports: [ConfirmDialogModule]
providers: [ConfirmationService]

private readonly confirm = inject(ConfirmationService);

eliminar(id: string): void {
  this.confirm.confirm({
    message: '¿Eliminar este vehículo?',
    header: 'Confirmar',
    accept: () => this.fleetSvc.delete(id).subscribe()
  });
}
```
```html
<p-confirmdialog />  <!-- en main-layout.html -->
```

### Stepper (onboarding / registro multi-paso)
```typescript
imports: [StepperModule]
```
```html
<p-stepper [value]="1">
  <p-step-list>
    <p-step [value]="1">Datos de empresa</p-step>
    <p-step [value]="2">RUC y verificación</p-step>
    <p-step [value]="3">Usuario administrador</p-step>
  </p-step-list>
  <p-step-panels>
    <p-step-panel [value]="1">...</p-step-panel>
    <p-step-panel [value]="2">...</p-step-panel>
    <p-step-panel [value]="3">...</p-step-panel>
  </p-step-panels>
</p-stepper>
```

### Chart (dashboard métricas)
```typescript
imports: [ChartModule]

readonly chartData = computed(() => ({
  labels: ['Ene', 'Feb', 'Mar'],
  datasets: [{
    label: 'Envíos completados',
    data: [12, 19, 8],
    backgroundColor: '#3b82f6'
  }]
}));
```
```html
<p-chart type="bar" [data]="chartData()" [options]="{ responsive: true }" />
```

---

## 11. Tailwind v4 — diferencias vs v3

```css
/* ✅ v4 — no existe tailwind.config.js, todo va en CSS */
@import "tailwindcss" layer(tailwind-base);
@import "tailwindcss/utilities" layer(tailwind-utilities);

/* ✅ v4 — variables CSS nativas para customización */
@theme {
  --color-logyx-blue: #2563eb;
  --color-logyx-dark: #1e293b;
  --font-family-sans: 'Inter', sans-serif;
}

/* ❌ v4 — NO existe @apply con clases de Tailwind en component styles */
/* Usar clases directamente en el template */
```

**Clases más usadas en el proyecto:**
```html
<!-- Layouts -->
<div class="flex items-center gap-4">
<div class="grid grid-cols-3 gap-6">
<div class="flex flex-col h-screen overflow-hidden">

<!-- Cards / contenedores -->
<div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">

<!-- Tipografía -->
<h1 class="text-2xl font-bold text-gray-800">
<p class="text-sm text-gray-500">
<span class="text-xs font-medium uppercase tracking-wide text-gray-400">

<!-- Estados de color semafórico -->
<span class="text-green-600 bg-green-50 px-2 py-1 rounded-full text-xs font-medium">  <!-- success -->
<span class="text-yellow-600 bg-yellow-50 ...">  <!-- warning -->
<span class="text-red-600 bg-red-50 ...">         <!-- danger -->
<span class="text-blue-600 bg-blue-50 ...">       <!-- info -->
```

---

## 12. Estructura de rutas — ubicación de archivos

```
app.routes.ts                    ← rutas raíz (layouts + lazy feature routes)
features/auth/auth.routes.ts     ← AUTH_ROUTES
features/pyme/pyme.routes.ts     ← PYME_ROUTES
features/carrier/carrier.routes.ts   ← CARRIER_ROUTES
features/operator/operator.routes.ts ← OPERATOR_ROUTES
```

**Para agregar una nueva pantalla a pyme:**
1. Crear `features/pyme/nueva/nueva.ts`
2. Agregar en `pyme.routes.ts`:
   ```typescript
   { path: 'nueva', loadComponent: () => import('./nueva/nueva').then(m => m.NuevaComponent) }
   ```
3. Agregar en `main-layout.ts` > `NAV_BY_ROLE.PYME` si debe aparecer en el sidebar.

---

## 13. Modelos — dónde están y cómo importar

Todos los tipos del dominio están en un solo archivo:
```typescript
import { ShipmentRequest, Bid, Profile, Vehicle } from '../../../core/models';
// o desde features al mismo nivel:
import { ShipmentRequest } from '../../core/models';
```

Ajustar `../../..` según la profundidad del componente:
- `features/pyme/dashboard/` → `../../../core/models`
- `layout/main-layout/` → `../../core/models`
- `shared/components/badge/` → `../../../core/models`

---

## 14. ApiService — cómo llamar al backend

```typescript
private readonly api = inject(ApiService);

// GET con query params
this.api.get<PageResponse<ShipmentRequest>>('/shipment-requests', { page: 0, size: 20 });

// GET por id
this.api.get<ShipmentRequest>(`/shipment-requests/${id}`);

// POST
this.api.post<ShipmentRequest>('/shipment-requests', dtoObjeto);

// PATCH
this.api.patch<Shipment>(`/shipments/${id}/stops/${stopId}`, { status: 'DELIVERED' });

// DELETE
this.api.delete<void>(`/vehicles/${id}`);

// Upload de archivo
const form = new FormData();
form.append('file', file);
form.append('type', 'DELIVERY_PHOTO');
this.api.postForm<Document>(`/shipments/${id}/documents`, form);
```

El `jwtInterceptor` inyecta el token automáticamente. Si el servidor responde 401, hace logout automático.

---

## 15. Providers globales en app.config.ts

```typescript
// Estado actual de app.config.ts — agregar providers aquí, no crear módulos
providers: [
  provideBrowserGlobalErrorListeners(),
  provideRouter(routes, withComponentInputBinding()),
  provideHttpClient(withFetch(), withInterceptors([jwtInterceptor])),
  provideAnimationsAsync(),
  providePrimeNG({ theme: { preset: LogyxPreset, options: { ... } } }),
  MessageService,   // ← Toast, ver sección 16
  // ConfirmationService,  ← para ConfirmDialog, agregar cuando se necesite
]
```

---

## 16. Design System — tokens, tema y componentes reutilizables

Especificación visual (estilo "LogiSmart"): fondos claros, sidebar blanco con ítem
activo en azul-slate oscuro sólido, cards con esquinas muy redondeadas y borde
izquierdo de acento, tablas de datos minimalistas con badges de prioridad pastel.

### 16.1 Tokens (`src/styles.css`)

Definidos con `@theme` de Tailwind v4 — generan utilidades automáticamente
(`bg-primary`, `text-danger`, `border-l-success`, etc.), **no crear clases custom
para colores, usar siempre estas utilidades**:

| Token | Valor | Uso |
|---|---|---|
| `--color-primary` | `#0F172A` (Slate 900) | Sidebar activo, botones primarios, títulos |
| `--color-secondary` | `#334155` (Slate 700) | Subtextos, texto secundario |
| `--color-surface` | `#EEF2F6` (≈ Slate 100) | Fondo general de la app — deliberadamente más oscuro que las cards (blancas) para que se distingan sin depender de sombras pesadas |
| `--color-neutral` | `#787778` | Bordes y textos decorativos |
| `--color-success` | `#10B981` | Deltas positivos, badges OK |
| `--color-danger` | `#EF4444` | Alertas críticas, urgente |
| `--color-warning` | `#F59E0B` | Prioridad media/alta |
| `--color-info` | `#3B82F6` | Prioridad baja, informativo |
| `--font-sans` | Inter + fallback | Fuente global (cargada en `index.html` vía Google Fonts) |

Radios de card: usar `rounded-xl` (12px) o `rounded-2xl` (16px) del propio Tailwind,
no se agregaron tokens custom de radius.

### 16.2 Tema PrimeNG (`app.config.ts`)

`LogyxPreset = definePreset(Aura, { semantic: { primary: { ...escala Slate } } })`
— alinea el `primary` de PrimeNG (botones, checkboxes, inputs focus) con la escala
Slate de Tailwind. Si se necesita tocar otro semantic token (surface, formField,
etc.) extender el mismo `definePreset` en `app.config.ts`, no crear un preset nuevo.

### 16.3 Componentes reutilizables (`src/app/shared/ui/`)

Wrappers delgados sobre Tailwind/PrimeNG — no reemplazan PrimeNG, añaden las
variantes de negocio del diseño. Antes de escribir HTML/CSS a mano para badges,
KPIs, progreso o widgets de analítica en una feature nueva, revisar si ya existe
aquí:

| Componente | Selector | Uso |
|---|---|---|
| `BadgeComponent` | `<app-badge [tone]="...">` | Tonos: `success\|danger\|warning\|info\|neutral`. Helper `priorityTone(priority)` mapea `URGENT/HIGH/MEDIUM/LOW` → tono. |
| `KpiCardComponent` | `<app-kpi-card [title] [value] [icon] [accent] [delta] [context]>` | Tarjeta de métrica superior con borde de acento y badge de delta %. |
| `ProgressBarComponent` | `<app-progress-bar [value]="72">` | Cápsula minimalista gris + relleno primary + % a la derecha. |
| `AnalyticsCardComponent` | `<app-analytics-card [title] [points] [metrics]>` | Widget lateral: sparkline de barras + sub-métricas con icono cuadrado oscuro. |

Ejemplo de referencia completo usando los cuatro: `src/app/features/operator/dashboard/operator-dashboard.ts`.

### 16.4 Notificaciones (Toast)

`NotificationService` (`core/services/notification.service.ts`) envuelve
`MessageService` de PrimeNG: `.success(msg)`, `.info(msg)`, `.warn(msg)`,
`.error(err, fallback)` — este último ya usa `extractErrorMessage` internamente,
no llamar `extractErrorMessage` de nuevo en el componente si se usa este servicio.
El `<p-toast />` global vive en `app.ts`, no agregar otro en cada feature.

### 16.5 Layout (sidebar + topbar)

`MainLayoutComponent` ya sigue la especificación: logo cuadrado `bg-primary` +
nombre, ítems de nav con `routerLinkActive="bg-primary text-white"`, topbar con
título de la vista actual (derivado automáticamente de `navItems` + URL activa,
ver `pageTitle` computed) y bloque de usuario a la derecha con avatar + rol.
Al agregar una ruta nueva a `NAV_BY_ROLE`, el título del topbar se resuelve solo —
no hace falta tocar nada más.

### 16.6 Animación de validación en inputs

`styles.css` define un `@keyframes shake` global aplicado a `.ng-invalid.ng-touched`
— no requiere lógica en TS ni directivas. Angular ya añade esas clases al host del
control (el `<input>` nativo, o el propio `<p-password>`/`<p-select>`/etc. cuando
el `formControlName` está en el componente PrimeNG) apenas el campo pasa a
inválido+touched, y el navegador reinicia la animación cada vez que el elemento
empieza a matchear el selector. Para que un campo dispare el shake basta con que
use `formControlName`/`[formControl]` — no hace falta agregar `[class.ng-invalid]`
manual (ya es redundante, ver `login.html` para un ejemplo a limpiar si se toca ese archivo).

---

*LOGYX · Guía Frontend · Angular 22 + Tailwind v4 + PrimeNG 21 · Julio 2026*
